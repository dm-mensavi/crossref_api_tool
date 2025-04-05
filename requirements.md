
---

# Crossref API Tool – Requirements and Setup

This document lists the software dependencies and setup instructions for running the **Crossref API Tool**, a Bash script for retrieving scientific article information from the Crossref REST API.

Before using the script, ensure the following packages are installed on your Linux system.

---

## 📦 Required Software

1. **curl**
   - **Purpose**: Makes HTTP requests to the Crossref API.
   - **Installation**:
     - Ubuntu/Debian:
       ```bash
       sudo apt update
       sudo apt install curl
       ```
     - Fedora:
       ```bash
       sudo dnf install curl
       ```
     - Arch Linux:
       ```bash
       sudo pacman -S curl
       ```

2. **jq**
   - **Purpose**: Command-line JSON processor used to parse API responses.
   - **Installation**:
     - Ubuntu/Debian:
       ```bash
       sudo apt update
       sudo apt install jq
       ```
     - Fedora:
       ```bash
       sudo dnf install jq
       ```
     - Arch Linux:
       ```bash
       sudo pacman -S jq
       ```

3. **rofi**
   - **Purpose**: Window switcher and application launcher used for interactive menus.
   - **Installation**:
     - Ubuntu/Debian:
       ```bash
       sudo apt update
       sudo apt install rofi
       ```
     - Fedora:
       ```bash
       sudo dnf install rofi
       ```
     - Arch Linux:
       ```bash
       sudo pacman -S rofi
       ```

4. **xclip**
   - **Purpose**: Enables copying search results to the clipboard.
   - **Installation**:
     - Ubuntu/Debian:
       ```bash
       sudo apt update
       sudo apt install xclip
       ```
     - Fedora:
       ```bash
       sudo dnf install xclip
       ```
     - Arch Linux:
       ```bash
       sudo pacman -S xclip
       ```

---

## ✅ Verification

After installation, verify that each tool is correctly installed by running:

```bash
curl --version
jq --version
rofi --version
xclip -version
```

If any command fails, revisit the installation steps for that package.

---

## 📋 Notes

- This tool is designed for **Linux** systems with a **Bash** shell.
- Ensure you have an **active internet connection** as the script interacts with the Crossref API online.
- No API keys or additional configuration files are required — Crossref offers open access for basic queries.

---

## 🚀 How to Run the Script

1. Place the following files in the **same directory**:
   - `crossref_tool.sh`
   - `functions.sh`
   - `config.rasi`
   - `requirements.txt` (this file)

2. Make the scripts executable:

   ```bash
   chmod +x crossref_tool.sh functions.sh
   ```

3. Run the main script:

   ```bash
   ./crossref_tool.sh
   ```

---

## 🛠️ Troubleshooting

- If you encounter issues, verify that all dependencies are installed.
- Check the terminal output for any error messages.

**Important**:  
If keyboard search input appears in the terminal instead of the `rofi` input field, press `Enter` to display your search term as a list item in `rofi`. Then, click on the list item to send the request to the API.

---
