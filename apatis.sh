#!/bin/bash

# =============================================================
# APATIS - Analysis Protection Against Threats & Insecure Scripts
# 🛡️ Alat Pendeteksi Link Phishing & Script Jebakan
# Script By Ronis
# =============================================================

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}  [ A.P.A.T.I.S ] ${NC}"
echo -e "${CYAN}  Analysis Protection Against Threats & Insecure Scripts${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${YELLOW}Author :${NC} Ronis"
echo -e "  ${YELLOW}Status :${NC} Monitoring Active"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Input URL
read -p "Masukkan URL/Link : " target

if [[ -z "$target" ]]; then
    echo -e "${RED}[!] Error: Link tidak boleh kosong!${NC}"
    exit 1
fi

echo -e "\n${CYAN}[*] Memulai Proses Scanning...${NC}"
sleep 1

# --- TAHAP 1: CEK URL ---
echo -e "${WHITE}[1] Menganalisis Struktur Link...${NC}"

# Cek Pemendek URL
if [[ "$target" =~ (bit\.ly|tinyurl\.com|goo\.gl|is\.gd|t\.co|cutt\.ly) ]]; then
    echo -e "    ${RED}[!] PERINGATAN: Link ini disembunyikan (Shortlink).${NC}"
    echo -e "    Potensi Phishing: TINGGI"
else
    echo -e "    ${GREEN}[✓] Struktur Link Transparan.${NC}"
fi

# Cek Typo-Squatting (GitHub Palsu)
if [[ "$target" == *"github"* ]]; then
    if [[ "$target" != *"github.com"* && "$target" != *"raw.githubusercontent.com"* ]]; then
         echo -e "    ${RED}[!] BAHAYA: Terdeteksi GitHub Palsu/Tiruan!${NC}"
    else
         echo -e "    ${GREEN}[✓] Domain GitHub Resmi.${NC}"
    fi
fi

# --- TAHAP 2: CEK KONTEN SCRIPT ---
echo -e "\n${WHITE}[2] Scanning Kode Script (Raw Content)...${NC}"

# Download file sementara
tmp="apatis_data.tmp"
curl -s -L "$target" > "$tmp"

if [ -s "$tmp" ]; then
    # Indikator Bahaya
    danger=0

    # Cek Perintah Hapus Data
    if grep -Ei "rm -rf /|rm -rf \$HOME|rm -rf /sdcard" "$tmp" > /dev/null; then
        echo -e "    ${RED}[🚨] TERDETEKSI: Perintah Penghapusan Data (Wiping)!${NC}"
        danger=$((danger+1))
    fi

    # Cek Backdoor/Remote Access
    if grep -Ei "nc -e|bash -i|/dev/tcp/" "$tmp" > /dev/null; then
        echo -e "    ${RED}[🚨] TERDETEKSI: Script mengandung Backdoor/Reverse Shell!${NC}"
        danger=$((danger+1))
    fi

    # Cek Fork Bomb
    if grep -q ":(){ :|:& };:" "$tmp"; then
        echo -e "    ${RED}[🚨] TERDETEKSI: Fork Bomb (Dapat membuat sistem crash)!${NC}"
        danger=$((danger+1))
    fi

    # Cek Enkripsi (Base64) - Sering dipakai sembunyikan malware
    if grep -q "base64 -d" "$tmp" || grep -q "eval" "$tmp"; then
        echo -e "    ${YELLOW}[!] WASPADA: Script dienkripsi (Obfuscated). Isi asli tersembunyi.${NC}"
    fi

    echo -e "-----------------------------------------------------"
    if [ $danger -eq 0 ]; then
        echo -e "${GREEN}[RESULT] APATIS menyimpulkan link/script ini RELATIF AMAN.${NC}"
    else
        echo -e "${RED}[RESULT] APATIS menyimpulkan link/script ini BERBAHAYA (${danger} Ancaman).${NC}"
    fi
else
    echo -e "    ${RED}[!] Gagal mengambil data. Link mungkin bukan file teks atau mati.${NC}"
fi

# Cleanup
rm -f "$tmp"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${WHITE}Scan Selesai - Script By Ronis${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
