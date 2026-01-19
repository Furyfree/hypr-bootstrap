### Fuldt Homelab-Setup – Januar 2026

#### Hardware
- **Compute-server** (ankommer slut januar)
  - Minisforum MS-A2
  - AMD Ryzen 9 9955HX (16 cores / 32 threads)
  - 64 GB RAM
  - 1 TB NVMe + ekstra M.2 slots
  - Networking: Dual 10G SFP+ + 2.5GbE
  - Rolle: Hypervisor med Proxmox VE – kører alle VM'er og services

- **Storage-server** (skal bestilles)
  - TerraMaster F4-424 Pro
  - Intel Core i3-N305 (8 cores)
  - 32 GB DDR5 RAM stock
  - Dual 2.5GbE
  - 2 × M.2 NVMe (til boot/cache)
  - Drives: 4 × 8 TB Seagate IronWolf Pro
  - **ZFS Pool**: RAIDZ2 (dobbelt redundancy – tåler 2 drive-fejl samtidigt)
  - **Reel brugbar plads**: Ca. **14-15 TB** (efter parity + ZFS overhead)
  - Rolle: Dedikeret TrueNAS Scale bare-metal (kun storage backend)

- **UPS** (anbefalet tilføjelse – for graceful shutdown ved power outage)
  - CyberPower CP1350EPFCLCD (1350 VA / 810 W, pure sine wave)
  - Pris: Ca. 2.200–2.500 kr
  - Tilsluttes: MS-A2 (compute), TerraMaster (NAS), UDM Pro og USW Pro Max POE 16
  - Konfiguration: NUT (Network UPS Tools) med 60-sekunders timer – sender shutdown-signal til alt hvis strøm ikke tilbage inden 1 minut
  - Runtime: ~15-25 min ved dit load (~150-250 W)

#### Network og Smart Home (Unifi All-In – erstatning for Verisure)
- Router: Unifi Dream Machine Pro
- Switche: 1 × USW Pro Max POE 16
- Access Points: 1 × U7 Lite + 2 × U7 Pro + 1 × U7 Pro Wall
- Kameraer: Unifi Protect G4/G5-serien
- Sensorer: Door/window, motion, leak osv.
- Kabling: Cat6a eller højere
- VLANs til separation (IoT, storage, gæster osv.)

#### Platforme og Integration
- **Proxmox VE** på Minisforum MS-A2
- **TrueNAS Scale** på TerraMaster (ZFS snapshots, replication, compression)
- **Integration**:
  - iSCSI (til VM-disks – høj performance)
  - NFS (til filer/backups/ISOs)
  - Networking mellem compute og storage: Dual 2.5GbE (op til 5 Gbps aggregated via LACP)

#### VM-opsætning på Proxmox (MS-A2)
- **Docker-VM** (Ubuntu/Debian – **alle Docker-containers kører i én enkelt VM**)
  - Docker Compose med Dockge som UI/manager
  - Services:
    - Grafana + simpel logging
    - Uptime Kuma (monitoring)
    - Immich (photo management – Dropbox/iCloud-erstatning)
    - Fileshare (OpenCloud)
    - Authentik (central authentication + forward auth)
    - n8n (automation workflows)
    - **BookStack** (selv-hostet wiki – "husets bog" til homelab-dokumentation, guides og familie-info)
- **Home Assistant-VM** (dedikeret – separat VM)
  - Fuld integration med Unifi Protect, sensorer og smart home
  - Erstatning for Verisure-alarm (notifications, automations, recording)

#### Eksponering og Security
- **OVH VPS** (billig, f.eks. VPS-1/Eco) som dedikeret ingress
  - Traefik som reverse proxy (automatiske Let's Encrypt certs, dashboard, middlewares)
  - Forward auth med Authentik
- **WireGuard-tunnel** fra VPS hjem til MS-A2 (ingen porte åbne hjemme)
- **Cloudflare** som DNS-provider (DDoS-protection og caching)

#### Backup og Observability
- **Lokalt**: Proxmox Backup Server (PBS) + TrueNAS snapshots
- **Offsite**: Hetzner Storage Box (billigst i DK/Europa – RSYNC/SFTP sync af kritiske datasets som Immich-fotos og configs)
- **Monitoring**: Grafana

#### Version Control og Automation
- Privat GitHub-repo med:
  - Docker Compose-filer
  - Traefik-config og labels
  - Ansible-scripts eller anden IaC

#### Økonomiske og Praktiske Fordele
- **Erstatter**:
  - Dropbox Professional (3 TB): **~199 USD/år** (ca. 1.400 kr/år inkl. moms)
  - iCloud+ 6 TB: **~59,99 USD/måned** (ca. 3.000 kr/år inkl. moms)
  - Verisure alarm: **12.000 kr/år**
  - **Gamle total løbende**: ~16.400 kr/år (med iCloud 6 TB)
- **Nyt homelab**:
  - Engangskøb: ~25.000–35.000 kr (MS-A2 + TerraMaster + drives + Unifi udstyr + UPS)
  - Løbende: ~3.000–6.000 kr/år (strøm, VPS, offsite)
- **Besparelse**: Betaler sig selv på 2-3 år + fuld privacy, ubegrænset storage og ingen vendor lock-in
- Bonus som cyberteknologi-studerende: Perfekt læringsprojekt til netværk, security, storage og automation (godt til CSE-portfolio)