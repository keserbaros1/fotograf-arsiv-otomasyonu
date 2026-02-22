# 📸 Fotoğraf Tarama ve İşleme Otomasyonu

Bu proje, eski fotoğraflarınızı yüksek çözünürlükte (RAW TIFF) tarayıp, ardından otomatik olarak kesme, yüz tanıma ile döndürme ve yeni nesil formatlarda (AVIF/HEIC) sıkıştırma işlemlerini yapmak için tasarlanmıştır. Ayrıca Home Assistant entegrasyonu ile tarama işlemlerini akıllı evinizden yönetebilirsiniz.

## 🚀 Özellikler

- **Tarama (`scan.sh`):** Belirlediğiniz profillere (A4, 10x15, Vesikalık vb.) göre sadece gerekli alanı tarayarak zamandan ve disk alanından tasarruf sağlar.
- **Otomatik Kesim (`sabit_kirp.py`):** Tek seferde taranan birden fazla fotoğrafı (örn: 4 adet 10x15) otomatik olarak ayrı dosyalara böler.
- **Yüz Tanıma ile Döndürme (`yuz_dondur.py`):** Ters taranmış fotoğrafları OpenCV yüz tanıma modeli ile tespit edip otomatik olarak düzeltir.
- **Kayıpsız Sıkıştırma:** Devasa TIFF dosyalarını, renk profillerini (ICC) koruyarak AVIF veya HEIC formatında kayıpsız (lossless) veya kayıplı olarak sıkıştırır.
- **Ağ Desteği:** İşlenecek dosyaları ve çıktıları yerel diskte veya ağ sürücüsünde (SMB/CIFS) tutabilirsiniz.
- **Home Assistant Entegrasyonu:** Tarayıcınızı Home Assistant arayüzünden kontrol edebilir, anlık durumunu takip edebilirsiniz.

---

## 🛠️ Kurulum ve Kullanım

### 1. Gereksinimler
İşlem betiği (`isle_fotolari.sh`) ilk çalıştığında gerekli paketleri otomatik olarak kuracaktır. Ancak manuel kurmak isterseniz:
```bash
sudo apt-get update
sudo apt-get install cifs-utils libavif-bin libheif-examples python3-opencv python3-pil
```

### 2. Fotoğrafları İşleme (`isle_fotolari.sh`)
Taranmış ham TIFF dosyalarını işlemek için betiği `sudo` yetkisiyle çalıştırın. Betik size adım adım ne yapmak istediğinizi soracaktır:
```bash
sudo bash isle_fotolari.sh
```
*Not: Betik `sudo` ile çalışsa bile, oluşturulan dosyaların sahipliği komutu çalıştıran asıl kullanıcıya verilir.*

### 3. Tarama Yapma (`scan.sh`)
Tarayıcınızın bağlı olduğu Linux makinesinde doğrudan çalıştırabilirsiniz:
```bash
bash scan.sh
```
Size tarama profili ve DPI seçeneklerini sunacaktır.

---

## 🏠 Home Assistant Entegrasyonu

Tarayıcınızı Home Assistant üzerinden kontrol etmek için aşağıdaki adımları izleyin.

### 1. `configuration.yaml` Ayarları
Home Assistant'ın `configuration.yaml` dosyasına gerekli `input_select`, `sensor` ve `shell_command` tanımlamalarını ekleyin. (Örnek yapılandırma için projedeki `ha_configuration_example.yaml` dosyasına bakabilirsiniz).

### 2. SSH Anahtarı
Home Assistant'ın tarayıcının bağlı olduğu sunucuya şifresiz bağlanabilmesi için bir SSH anahtarı oluşturup sunucuya kopyalamanız gerekir:
```bash
# Home Assistant terminalinde:
ssh-keygen -t rsa -b 4096 -f /config/ssh_key
ssh-copy-id -i /config/ssh_key kullanici_adi@sunucu_adresi
```

```bash
#Test Komutu
ssh -i /config/ssh_key -o StrictHostKeyChecking=no kullanici_adi@sunucu_adresi "echo Bağlantı Başarılı"
```

### 3. Lovelace (Arayüz) Kartı
Home Assistant panonuza yeni bir kart ekleyin ve `ha_lovelace_card.yaml` dosyasındaki kodu yapıştırın.

---

## ⚙️ Profilleri Özelleştirme

Kesim profillerini değiştirmek veya yenilerini eklemek için `sabit_kirp.py` dosyasındaki `PROFILLER` sözlüğünü düzenleyebilirsiniz. Koordinatlar (x, y) ve boyutlar (w, h) fotoğrafın yüzdelik oranını (0.00 - 1.00) temsil eder.

Tarama profillerini değiştirmek için ise `scan.sh` dosyasındaki `PROFIL_X` ve `PROFIL_Y` dizilerini düzenleyebilirsiniz (Değerler milimetre cinsindendir).
