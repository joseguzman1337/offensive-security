"""Add Checkov skip as comments."""

import logging
import sys

# Defining constants for file paths and assumed keys.
CHECKOV_REPORT = "git-error-13Dic241619.yaml"
FILE_PATH_CONSTANT = "file_path"
START_LINE = "file_line_range"

# Configuring logging to output to the console in real-time.
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)


def add_checkov_skip(
    file_path_1: str,
    target_line: int,
    skip_comment: str = "# checkov:skip=CKV_AWS_363:"
    "Upgrade to a supported Go runtime when feasible",
) -> None:
    """
    Adds a Checkov skip comment to a file at a specific line,
    after the line containing "Type: AWS::Lambda::Function".
    Removes duplicate CKV_AWS_363 comments.
    """
    logging.info("Processing file: %s", file_path_1)

    try:
        # Open the file in read mode.
        logging.debug("Opening file: %s", file_path_1)
        with open(file_path_1, "r", encoding="utf-8") as f1:
            lines_1 = f1.readlines()
        logging.debug("File opened successfully: %s", file_path_1)
    except FileNotFoundError:
        # Log an error if the file is not found.
        logging.error("File not found: %s", file_path_1)
        return
    except OSError as e:
        # Log an error if there is an issue reading the file.
        logging.error(
            "An error occurred while reading the file %s: %s",
            file_path_1,
            e,
        )
        return

    # Find the line number containing "Type: AWS::Lambda::Function"
    logging.debug(
        "Searching for line containing " '"Type: \\"AWS::Lambda::Function\\"" in %s',
        file_path_1,
    )

    # Adjust target line to 0-based indexing
    target_line -= 1

    try:
        type_line_number = lines_1.index('Type: "AWS::Lambda::Function"\n', target_line)
    except ValueError:
        logging.warning(
            "Could not find the line containing "
            '"Type: \\"AWS::Lambda::Function\\"" '
            "near line %d in %s",
            target_line + 1,
            file_path_1,
        )
        return

    logging.debug(
        'Found "Type: \\"AWS::Lambda::Function\\"" ' "at line: %s",
        type_line_number,
    )

    # Remove existing CKV_AWS_363 comments and log the action.
    ckv_aws_363_found = False
    new_lines = []
    for line_2 in lines_1:
        if line_2.startswith(
            ("# checkov:skip=CKV_AWS_363:", "#checkov:skip=CKV_AWS_363")
        ):
            if not ckv_aws_363_found:
                ckv_aws_363_found = True
            else:
                logging.info("Removing duplicate CKV_AWS_363 comment.")
        else:
            new_lines.append(line_2)
    lines_1 = new_lines

    # Insert the skip comment after the identified line
    lines_1.insert(type_line_number + 1, skip_comment + "\n")
    # Log the addition of the skip comment.
    logging.info(
        "Added skip in %s, after line %s",
        file_path_1,
        type_line_number + 1,
    )

    try:
        # Open the file in write mode and write the modified lines.
        logging.debug("Writing changes to file: %s", file_path_1)
        with open(file_path_1, "w", encoding="utf-8") as f2:
            f2.writelines(lines_1)
        logging.debug("Changes written successfully to file: %s", file_path_1)
    except OSError as e:
        # Log an error if there is an issue writing to the file.
        logging.error(
            "An error occurred while writing to the file %s: %s",
            file_path_1,
            e,
        )


if __name__ == "__main__":
    # Logic to extract findings and add skips.
    logging.debug("Starting the script...")

    try:
        logging.debug("Opening Checkov report: %s", CHECKOV_REPORT)
        with open(CHECKOV_REPORT, "r", encoding="utf-8") as f3:
            lines_2 = f3.readlines()
        logging.debug("Checkov report opened successfully: %s", CHECKOV_REPORT)
    except FileNotFoundError:
        logging.error("File not found: %s", CHECKOV_REPORT)
        sys.exit(1)
    except OSError as e:
        logging.error(
            "An error occurred while reading the file %s: %s", CHECKOV_REPORT, e
        )
        sys.exit(1)

    # This part makes assumptions about the file structure
    # and may need adjustments based on the actual format.
    # It currently assumes the file contains lines like:
    # "file_path: /path/to/file.py"
    # "file_line_range: [123]"
    FILE_PATH_VAR = None
    START_LINE_VAR = None
    FINDING_COUNT = 0
    i = 0
    while i < len(lines_2):
        line_3 = lines_2[i]
        if line_3.startswith(FILE_PATH_CONSTANT + ":"):
            FILE_PATH_VAR = line_3.split(":")[1].strip()
            logging.debug("Found file path at line %d: %s", i, FILE_PATH_VAR)
        elif line_3.startswith(START_LINE + ":"):
            try:
                START_LINE_VAR = int(line_3.split(":")[1].strip().strip("[]"))
                logging.debug("Found start line at line %d: %s", i, START_LINE_VAR)
            except ValueError:
                logging.warning("Invalid line number format at line %d: %s", i, line_3)
                i += 1
                continue

            if FILE_PATH_VAR and START_LINE_VAR:
                FINDING_COUNT += 1
                logging.debug("Processing finding %d...", FINDING_COUNT)
                add_checkov_skip(FILE_PATH_VAR, START_LINE_VAR)
                FILE_PATH_VAR = None
                START_LINE_VAR = None
        i += 1

    if FINDING_COUNT == 0:
        logging.warning("No findings were processed.")

    logging.debug("Script finished.")
