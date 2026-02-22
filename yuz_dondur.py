import cv2
import sys
import numpy as np
from PIL import Image

# OpenCV'nin hazır yüz tanıma modeli
YUZ_MODELI = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

def yuzu_bul_ve_dondur(resim_yolu):
    # OpenCV ile okuma (Sadece analiz için, kaydederken Pillow kullanacağız ki renkler bozulmasın)
    cv_img = cv2.imread(resim_yolu)
    if cv_img is None: return

    gray = cv2.cvtColor(cv_img, cv2.COLOR_BGR2GRAY)
    
    # 4 yönü test et (0, 90, 180, 270 derece saat yönü)
    yonler = [
        (0, None), 
        (270, cv2.ROTATE_90_CLOCKWISE), 
        (180, cv2.ROTATE_180), 
        (90, cv2.ROTATE_90_COUNTERCLOCKWISE)
    ]

    en_iyi_aci = 0
    en_buyuk_yuz_alani = 0


    for aci, donusum in yonler:
        test_img = gray
        if donusum is not None:
            test_img = cv2.rotate(gray, donusum)
        
        # Yüz ara
        yuzler = YUZ_MODELI.detectMultiScale(test_img, scaleFactor=1.1, minNeighbors=5, minSize=(100, 100))
        
	# Bulunan yüzlerin büyüklüğüne (alanına) bak
        for (x, y, w, h) in yuzler:
            alan = w * h
            # Eğer bu yönde bulduğumuz yüz, diğer yönlerde bulduklarımızdan daha büyükse
            # doğru açı budur diyoruz!
            if alan > en_buyuk_yuz_alani:
                en_buyuk_yuz_alani = alan
                en_iyi_aci = aci



    # Eğer döndürülmesi gerekiyorsa, işlemi Pillow ile yap (ICC Profilini korumak için)
    if en_iyi_aci != 0 and en_buyuk_yuz_alani > 0:
        print(f"   🔄 Yüz bulundu! {en_iyi_aci} derece döndürülüyor: {resim_yolu}")
        pil_img = Image.open(resim_yolu)
        icc = pil_img.info.get('icc_profile')
        
        # Pillow'da yönler saat yönünün tersidir, o yüzden hesapladığımız açıyı direkt verebiliriz
	# expand=True : Döndürürken köşelerin kesilmesini engeller
        pil_img = pil_img.rotate(en_iyi_aci, expand=True)
        pil_img.save(resim_yolu, 'PNG', icc_profile=icc)

if __name__ == "__main__":
    if len(sys.argv) == 2:
        yuzu_bul_ve_dondur(sys.argv[1])
