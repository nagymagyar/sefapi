# Sefapi - Séfbérlés Web API

Egyszerű ASP.NET Core Web API a séfbérlések kezelésére (InMemory DB).

Futtatás:

```powershell
dotnet restore
dotnet run
```

API végpontok:
- `GET /api/berlesek` - összes bérlés
- `GET /api/berlesek/{id}` - bérlés ID alapján
- `POST /api/berlesek` - új bérlés létrehozása (lásd validációs szabályok)
- `DELETE /api/berlesek/{id}` - törlés

POST validációs szabályok:
- Kezdőnap nem lehet korábbi, mint holnap.
- Időtartam legalább 3 nap, legfeljebb 14 nap.
- Ugyanarra a `chefId`-ra nem lehet átfedés.

Tesztelés helyben
-----------------

1. Klónozás után a projekt gyökérben:

```powershell
dotnet restore
dotnet run --urls http://localhost:5000
```

2. Nyisd meg a Swagger UI-t: `http://localhost:5000/swagger`

3. Automata teszt (PowerShell):

```powershell
# A szerver legyen futtatva (lásd 1.)
.\scripts\run-tests.ps1
```

4. Egyszerű curl tesztek (Unix / WSL):

```bash
bash scripts/run-tests.sh
```

Ezek a scriptek lefuttatják a POST/GET/DELETE kéréseket és ellenőrzik a validációs hibákat, valamint a sikeres létrehozást és a törlést.
