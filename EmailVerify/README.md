# Email Validation Script

## Overview

This Python script performs email validation by checking the format, domain, and SMTP verification of a list of email addresses. It uses SMTP credentials provided in a configuration file to verify the validity of email addresses. The results are saved incrementally to a CSV file, which helps in tracking the validation status of each email.

## Features

- Validates email format using regular expressions.
- Checks domain existence through DNS MX record lookups.
- Verifies email validity using SMTP.
- Saves validation results to a CSV file.
- Supports incremental processing to avoid rechecking already validated emails.
- Gracefully handles interruption (SIGINT) for a smooth shutdown.

## Requirements

- Python 3.x
- `argparse` (Standard Library)
- `re` (Standard Library)
- `smtplib` (Standard Library)
- `dns.resolver` (Install with `pip install dnspython`)
- `configparser` (Standard Library)
- `os` (Standard Library)
- `logging` (Standard Library)
- `csv` (Standard Library)
- `signal` (Standard Library)
- `sys` (Standard Library)

## Configuration

The script uses a configuration file (`config.ini`) for SMTP credentials. The file should have the following format:

```ini
[SMTP]
smtp_server = smtp.example.com
smtp_port = 587
username = your-email@example.com
password = your-password
```

## Usage
To run the script, use the following command line syntax:
```python
python script.py -l <email_file> -o <output_file> -c <config_file>
```

## Arguments
- `-l`, `--list`: Path to the text file containing email addresses (one per line). The default file is `emails.txt`.
- `-o`, `--output`: Path to the CSV file where the validation results will be saved. The default file is `validation_results.csv`.
- `-c`, `--config`: Path to the configuration file for SMTP credentials. The default file is `config.ini`.

## Script Details
1. Logging Configuration: Configures logging to output messages to the console with timestamps.
2. Configuration Loading: Reads SMTP credentials from the specified configuration file.
3. SMTP Validation: Attempts to establish an SMTP connection to verify credentials.
4. Email Validation: Checks the email address format, domain existence via DNS MX records, and performs SMTP verification.
5. Result Management: Appends validation results to a CSV file and skips already processed emails.
6. Signal Handling: Handles interruption signals to allow graceful termination.
