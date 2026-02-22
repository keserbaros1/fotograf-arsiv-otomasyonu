#!/bin/bash

# ==================================================
# ⚙️ AYARLAR VE PROFİLLER
# ==================================================
ANA_KLASOR="/mnt/z" # Varsayılan ana klasör, istersen değiştirebilirsin
HEDEF_KLASOR="$ANA_KLASOR/ham_tiff"
ZAMAN=$(date +"%Y%m%d_%H%M%S")
DOSYA="$HEDEF_KLASOR/scan_$ZAMAN.tiff"

# Klasör yoksa oluştur
mkdir -p "$HEDEF_KLASOR"

# --- TARAMA PROFİLLERİ (Genişlik x Yükseklik mm cinsinden) ---
# -x: Genişlik (mm), -y: Yükseklik (mm)
# 0.1 cm (1 mm) hata payı eklenmiştir.
declare -A PROFIL_X
declare -A PROFIL_Y
declare -A PROFIL_AD

# 1. A4 Tam Sayfa (Senin 4 fotoğraflı profilin: 2x 10x15 + 2x 10x13)
PROFIL_AD[1]="A4 Tam Sayfa (4 Fotoğraf: 2x 10x15 + 2x 10x13)"
PROFIL_X[1]=215
PROFIL_Y[1]=297

# 2. A4 Yarım Sayfa (Senin 2 fotoğraflı profilin: 2x 10x15)
PROFIL_AD[2]="A4 Yarım Sayfa Üst (2 Fotoğraf: 2x 10x15)"
PROFIL_X[2]=215
PROFIL_Y[2]=151

# 3. Tekli 10x15 (Dikey)
PROFIL_AD[3]="Tekli 10x15 (Dikey)"
PROFIL_X[3]=101
PROFIL_Y[3]=151

# 4. Tekli 15x10 (Yatay)
PROFIL_AD[4]="Tekli 15x10 (Yatay)"
PROFIL_X[4]=151
PROFIL_Y[4]=101

# 5. Tekli 13x18 (Dikey)
PROFIL_AD[5]="Tekli 13x18 (Dikey)"
PROFIL_X[5]=131
PROFIL_Y[5]=181

# 6. Tekli 18x13 (Yatay)
PROFIL_AD[6]="Tekli 18x13 (Yatay)"
PROFIL_X[6]=181
PROFIL_Y[6]=131

# 7. Tekli 20x25 (Dikey - 8x10 inç)
PROFIL_AD[7]="Tekli 20x25 (Dikey)"
PROFIL_X[7]=204
PROFIL_Y[7]=255


# 8. Vesikalık (4.5 x 6 cm)
PROFIL_AD[8]="Vesikalık (4.5x6)"
PROFIL_X[8]=46
PROFIL_Y[8]=61

# HA İÇİN DURUM DOSYASI
DURUM_DOSYASI="/home/{kullanici_adi}/scan_status.txt"

# DIŞARIDAN PARAMETRE GELDİ Mİ KONTROLÜ (Home Assistant için)
PARAM_PROFIL=$1
PARAM_DPI=$2

if [ -n "$PARAM_PROFIL" ] && [ -n "$PARAM_DPI" ]; then
    # Parametre geldiyse etkileşimli menüleri atla
    SECIM=$PARAM_PROFIL
    SECILEN_DPI=$PARAM_DPI
    
    # Geçersiz profil koruması
    if [ -z "${PROFIL_AD[$SECIM]}" ]; then SECIM=1; fi
    
    SECILEN_X=${PROFIL_X[$SECIM]}
    SECILEN_Y=${PROFIL_Y[$SECIM]}
    
    echo "⏳ Tarama Başlıyor... Profil: ${PROFIL_AD[$SECIM]} ($SECILEN_DPI DPI)" > "$DURUM_DOSYASI"
else
    # PARAMETRE YOKSA ESKİ USUL TERMİNALDEN SOR
    echo "=================================================="
    echo "🖨️  TARAMA PROFİLİ SEÇİMİ"
    echo "=================================================="
    for i in "${!PROFIL_AD[@]}"; do
        echo "  $i) ${PROFIL_AD[$i]} (X: ${PROFIL_X[$i]}mm, Y: ${PROFIL_Y[$i]}mm)"
    done | sort -n

    echo ""
    while true; do
        read -p "👉 Profil seçin (1-${#PROFIL_AD[@]}) [Varsayılan: 1]: " SECIM
        SECIM=${SECIM:-1}

        # Geçersiz seçim kontrolü
        if [ -z "${PROFIL_AD[$SECIM]}" ]; then
            echo "⚠️ Geçersiz seçim! Lütfen listedeki numaralardan birini girin."
            continue
        fi
        break
    done

    SECILEN_X=${PROFIL_X[$SECIM]}
    SECILEN_Y=${PROFIL_Y[$SECIM]}

    echo ""
    echo "=================================================="
    echo "🔍 DPI (ÇÖZÜNÜRLÜK) SEÇİMİ"
    echo "=================================================="
    echo "  1) 300 DPI (Hızlı, düşük kalite)"
    echo "  2) 600 DPI (Orta hız, iyi kalite)"
    echo "  3) 1200 DPI (Yavaş, en yüksek kalite) [Varsayılan]"
    echo ""
    while true; do
        read -p "👉 DPI seçin (1/2/3) [Varsayılan: 3]: " DPI_SECIM
        DPI_SECIM=${DPI_SECIM:-3}

        case $DPI_SECIM in
            1) SECILEN_DPI=300; break ;;
            2) SECILEN_DPI=600; break ;;
            3) SECILEN_DPI=1200; break ;;
            *) echo "⚠️ Geçersiz seçim! Lütfen 1, 2 veya 3 girin." ;;
        esac
    done
    echo "⏳ Tarama Başlıyor... Profil: ${PROFIL_AD[$SECIM]} ($SECILEN_DPI DPI)" > "$DURUM_DOSYASI"
fi

echo ""
echo "=================================================="
echo ">>> 1. TARAMA BAŞLIYOR ($SECILEN_DPI DPI - RAW TIFF)"
echo ">>> Profil: ${PROFIL_AD[$SECIM]}"
echo ">>> Tarama Alanı: X=$SECILEN_X mm, Y=$SECILEN_Y mm"
echo ">>> Sunucu sadece veriyi kaydediyor, dönüştürme yok."
echo "=================================================="

# --format=tiff : Sıkıştırmasız
# --mode=Color
# -x ve -y : Seçilen profile göre dinamik
# --progress çıktısını terminalde tek satırda güncellemek için tr ve awk kullanıyoruz
scanimage -d "{yazici_id}" \
  --format=tiff \
  --mode=Color \
  --resolution=$SECILEN_DPI \
  -l 0 -t 0 -x $SECILEN_X -y $SECILEN_Y \
  --progress 2>&1 > "$DOSYA" | tr '\r' '\n' | awk '/Progress:/ {printf "\r%s", $0; fflush()}'

echo "" # İlerleme çubuğundan sonra yeni satıra geç

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    BOYUT=$(du -h "$DOSYA" | cut -f1)
    echo "✅ Kaydedildi: $DOSYA ($BOYUT)"
    echo "✅ Bitti. Son Kayıt: scan_$ZAMAN.tiff ($BOYUT)" > "$DURUM_DOSYASI"
else
    echo "❌ HATA: Tarama başarısız! Lütfen tarayıcı bağlantısını kontrol edin."
    echo "❌ HATA: Tarayıcı bağlantısını kontrol edin!" > "$DURUM_DOSYASI"
fi