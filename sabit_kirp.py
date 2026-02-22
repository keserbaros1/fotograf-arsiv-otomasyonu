
import sys
import os
from PIL import Image

# Çok büyük TIFF dosyaları için PIL'in güvenlik sınırını kaldıralım
Image.MAX_IMAGE_PIXELS = None

PROFILLER = {
    # Senin belirlediğin: 2 Büyük, 1 Küçük, 1 Büyük yerleşimi
	# x yatay başlangıç. y diket başlangıç
	# w yatay uzunluk h dikey uzunluk
    "iki_buyuk_iki_kucuk": [
        # 1. SOL ÜST
        {"ad": "sol_ust", "x": 0.00, "y": 0.00, "w": 0.48, "h": 0.51},

        # 2. SAĞ ÜST
        {"ad": "sag_ust", "x": 0.52, "y": 0.00, "w": 0.48, "h": 0.51},

        # 3. SOL ALT
        {"ad": "sol_alt", "x": 0.00, "y": 0.57, "w": 0.48, "h": 0.43},

        # 4. SAĞ ALT
        {"ad": "sag_alt", "x": 0.52, "y": 0.57, "w": 0.48, "h": 0.43},
    ],
    
    # İleride kullanabileceğin örnek: Sadece 2 tane yan yana 10x15
    "iki_buyuk": [
        {"ad": "foto_1", "x": 0.00, "y": 0.00, "w": 0.48, "h": 1},
        {"ad": "foto_2", "x": 0.52, "y": 0.00, "w": 0.48, "h": 1},
    ]
}

def profilleri_listele():
    for profil in PROFILLER.keys():
        print(profil)

def islem_yap(dosya_yolu, cikis_klasoru, profil_adi="benim_sablon", kesilsin_mi="E"):
    print(f"🔪 İşleniyor (Pillow): {dosya_yolu}")
    
    try:
        img = Image.open(dosya_yolu)
        icc_profili = img.info.get('icc_profile') # 🎨 RENK PROFİLİNİ AL
    except Exception as e:
        print(f"❌ HATA: {e}")
        return

    dosya_adi = os.path.splitext(os.path.basename(dosya_yolu))[0]

    if kesilsin_mi.lower() != 'e':
        print("   > 🔄 Kesim atlandı, geçici kopya oluşturuluyor...")
        hedef_yol = os.path.join(cikis_klasoru, f"{dosya_adi}_tam.png")
        img.save(hedef_yol, 'PNG', icc_profile=icc_profili)
        return

    w_img, h_img = img.size
    secilen_profil = PROFILLER.get(profil_adi)

    if not secilen_profil:
        print(f"❌ HATA: '{profil_adi}' profili bulunamadı.")
        return

    for b in secilen_profil:
        # Koordinatları hesapla
        sol = int(b["x"] * w_img)
        ust = int(b["y"] * h_img)
        sag = int(sol + (b["w"] * w_img))
        alt = int(ust + (b["h"] * h_img))

        # Sınırları aşma
        sag = min(sag, w_img)
        alt = min(alt, h_img)

        parca = img.crop((sol, ust, sag, alt))
        hedef_yol = os.path.join(cikis_klasoru, f"{dosya_adi}_{b['ad']}.png")
        
        # 🎨 RENK PROFİLİ İLE KAYDET
        parca.save(hedef_yol, 'PNG', icc_profile=icc_profili)

if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--list-profiles":
        profilleri_listele()
        sys.exit(0)
        
    if len(sys.argv) == 2 and sys.argv[1] == "--default-profile":
        print(list(PROFILLER.keys())[0])
        sys.exit(0)

    if len(sys.argv) >= 3:
        profil = sys.argv[3] if len(sys.argv) > 3 else list(PROFILLER.keys())[0]
        kesilsin_mi = sys.argv[4] if len(sys.argv) > 4 else "E"
        islem_yap(sys.argv[1], sys.argv[2], profil, kesilsin_mi)
