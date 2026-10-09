# PostgreSQL lokal SignIt

Container: hackathon-postgres. Host: localhost. Port: 5434. Database: hackathondb.
Volume persisten: docker_postgres_data. PostgreSQL 16.
Jalankan dari root repository:

```powershell
docker compose -f infrastructure/docker/docker-compose.yml up -d database
```

Migration EF mencakup auth, letters/workflow/signatures, organizations, facilities dan facility_resources.
Script backend/provisioning/facilities.sql mengisi tujuh fasilitas secara idempoten.
SAW memiliki 49 ruangan; PS memiliki tiga ruangan terkonfirmasi; tiga lapangan adalah resource mandiri.
Lobby PS/SAW tidak dapat dipinjam. PS lantai 4–11 serta ruangan D3/D4 menunggu konfirmasi.

Organisasi belum diisi karena nama dan scope organisasi aktual belum diberikan.
Isi organizations dengan Id stabil, Scope yang cocok dengan assignment akun, Name,
Kind (Himpunan/Organisasi), dan IsActive. Routing membaca jenis organisasi dari tabel ini.

Kredensial compose saat ini adalah kredensial development lokal bawaan repository.
Gunakan secret/environment terpisah ketika deployment; jangan memakai kredensial ini di server.
Jangan menjalankan docker compose down -v karena menghapus volume database.
Katalog resource belum terhubung ke submit/reservasi dan constraint benturan jadwal belum tersedia.
