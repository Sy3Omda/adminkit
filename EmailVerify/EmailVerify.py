#!/usr/bin/env python3

import argparse
import re
import smtplib
import dns.resolver
import configparser
import os
import logging
import csv
import signal
import sys

# Set up logging to display messages on the console
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

DEFAULT_CONFIG_FILE = "config.ini"

def load_config(config_file):
    config = configparser.ConfigParser()
    config.read(config_file)
    return config

def validate_config(config):
    """ Validate SMTP credentials by trying to establish a connection. """
    try:
        server = smtplib.SMTP(config['SMTP']['smtp_server'], config['SMTP']['smtp_port'])
        server.starttls()
        server.login(config['SMTP']['username'], config['SMTP']['password'])
        server.quit()
        return True, "SMTP credentials are valid."
    except Exception as e:
        return False, f"SMTP credentials or configuration are invalid: {e}"

def validate_email(email, config):
    """ Validate the email by checking format, domain, and SMTP verification. """
    # Basic regex for email validation
    regex = r'^\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    if not re.match(regex, email):
        return False, "Invalid"

    domain = email.split('@')[1]

    try:
        records = dns.resolver.resolve(domain, 'MX')
    except Exception:
        return False, "Invalid"

    try:
        server = smtplib.SMTP(config['SMTP']['smtp_server'], config['SMTP']['smtp_port'])
        server.starttls()
        server.login(config['SMTP']['username'], config['SMTP']['password'])
        server.helo(server.local_hostname)
        server.mail(config['SMTP']['username'])
        code, _ = server.rcpt(email)
        server.quit()

        if code == 250:
            return True, "Valid"
        else:
            return False, "Invalid"
    except Exception:
        return False, "Invalid"

def save_result_incrementally(email, status, output_file):
    """ Save the result of each email to the output CSV file. """
    with open(output_file, 'a', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow([email, status])

def load_existing_results(output_file):
    """ Load existing results from the output file to skip already processed emails. """
    processed_emails = {}
    if os.path.exists(output_file):
        with open(output_file, 'r') as csvfile:
            reader = csv.reader(csvfile)
            next(reader)  # Skip header
            for row in reader:
                processed_emails[row[0]] = row[1]
    return processed_emails

def signal_handler(sig, frame):
    logging.info("Interrupt received, stopping process...")
    sys.exit(0)

def main(email_file, output_file, config_file=DEFAULT_CONFIG_FILE):
    # Check if output file exists and if not, write headers
    if not os.path.exists(output_file):
        with open(output_file, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Email Address', 'Validation Result'])

    if not os.path.exists(config_file):
        logging.error(f"Config file '{config_file}' not found.")
        return

    config = load_config(config_file)

    # Validate the SMTP credentials
    is_valid_config, config_message = validate_config(config)
    if not is_valid_config:
        logging.error(config_message)
        return
    else:
        logging.info(config_message)

    if not os.path.exists(email_file):
        logging.error(f"Email file '{email_file}' not found.")
        return

    # Load existing results to avoid rechecking emails
    processed_emails = load_existing_results(output_file)

    with open(email_file, 'r') as f:
        email_list = [line.strip() for line in f if line.strip()]

    for email in email_list:
        if email in processed_emails:
            logging.info(f"Skipping already processed email: {email}")
            continue

        is_valid, status = validate_email(email, config)
        logging.info(f"Email: {email} - Valid: {is_valid}")
        save_result_incrementally(email, status, output_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Validate a list of emails.")
    parser.add_argument("-l", "--list", help="Path to the text file containing emails.")
    parser.add_argument("-o", "--output", help="Path to the output CSV file.")
    parser.add_argument("-c", "--config", help="Path to the config file.", default=DEFAULT_CONFIG_FILE)
    args = parser.parse_args()

    email_file = args.list if args.list else 'emails.txt'
    output_file = args.output if args.output else 'validation_results.csv'
    config_file = args.config if args.config else DEFAULT_CONFIG_FILE

    # Handle SIGINT (Ctrl + C) gracefully
    signal.signal(signal.SIGINT, signal_handler)

    main(email_file, output_file, config_file)
