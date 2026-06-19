# Hurtownia Danych Stats19 (Road Safety Data Pipeline)

Projekt zawiera implementację potoku przetwarzania i transformacji brytyjskich danych o wypadkach drogowych (Stats19). Dane są czyszczone, transformowane do modelu wielowymiarowego, a następnie wizualizowane w panelu analitycznym.

## Architektura Systemu

Poniższy diagram przedstawia ogólny przepływ danych (data flow) w systemie:

![Architektura systemu](diagrams/overview.jpg)

Dane pobierane są ze źródeł, a następnie ładowane do analitycznej bazy danych. Następnie poddawane są wielowarstwowej transformacji, czyszczeniu oraz modelowaniu do ustrukturyzowanej formy, przygotowanej na potrzeby warstwy wizualizacji.

## Model Danych

Struktura hurtowni danych bazuje na wielowymiarowym modelu danych w architekturze konstelacji faktów. Została zaprojektowana pod kątem wydajności zapytań analitycznych oraz zachowania znormalizowanej reprezentacji współdzielonych wymiarów. Szczegółowy schemat relacji między tabelami faktów i wymiarów został załączony na końcu niniejszego dokumentu.

## Struktura Katalogu Projektu

Poniższe drzewo przedstawia strukturę plików w katalogu `dbt_project/` wraz z opisem przeznaczenia poszczególnych warstw transformacji:

```text
dbt_project/
├── macros/                       # Makra Jinja/SQL wielokrotnego użytku
│   └── map_ids.sql               # Makro mapujące identyfikatory słownikowe na czytelne etykiety
│
├── seeds/                        # Pliki referencyjne i słowniki (Seedy) ładowane bezpośrednio do bazy
│   └── dft_data_guide/
│       └── seed_data_guide.csv   # Oficjalny słownik wartości i kodów dla atrybutów Stats19
│
├── tests/                        # Niestandardowe testy poprawności danych (asercje SQL)
│   ├── assert_fatalities_less_than_casualties.sql
│   ├── assert_positive_number_of_vehicles.sql
│   └── assert_valid_coordinates.sql
│
└── models/
    ├── staging/                  # Warstwa wejściowa (Staging) - definicje zewnętrznych źródeł
    │   ├── src_stats19.yml       # Konfiguracja zewnętrznych plików CSV i ich parametrów
    │   ├── stg_casualties.sql    # Widok mapujący dane o ofiarach wypadków
    │   ├── stg_collisions.sql    # Widok mapujący dane o samych zdarzeniach (kolizjach)
    │   └── stg_vehicles.sql      # Widok mapujący dane o pojazdach
    │
    ├── intermediate/             # Warstwa pośrednia - czyszczenie, unifikacja typów i wyliczanie kluczy zastępczych
    │   ├── int_casualties.sql    # Wstępne czyszczenie i standaryzacja danych o ofiarach
    │   ├── int_collisions.sql    # Wyliczanie atrybutów czasowych (np. rush hour, pory dnia), integracja danych o ofiarach śmiertelnych
    │   └── int_vehicles.sql      # Transformacje i standaryzacja danych o pojazdach
    │
    └── marts/                    # Warstwa docelowa (Marts) - gotowe struktury analityczne
        ├── constellation/        # Wielowymiarowy model gwiazdy/konstelacji
        │   ├── dim_*.sql         # Tabele wymiarów (np. lokalizacja, czas, warunki atmosferyczne, profil uczestnika)
        │   ├── fact_*.sql        # Tabele faktów (np. fact_collision, fact_vehicle_involvement)
        │   └── constellation.yml # Definicje asercji testowych dla modelu wielowymiarowego
        │
        └── obt/                  # Modele typu OBT (One Big Table) pod wizualizację w BI
            ├── obt_collision.sql # Płaska, szeroka tabela denormalizująca fakty i wymiary kolizji
            ├── obt_casualty.sql  # Zdenormalizowany model dedykowany analizie ofiar zdarzeń
            ├── obt_vehicle.sql   # Zdenormalizowany model dedykowany analizie pojazdów
            └── obt.yml           # Konfiguracja semantyczna metryk i wymiarów dla integracji z Lightdash
```

## Wykorzystane Technologie

### 1. DuckDB ([link do dokumentacji](https://duckdb.org/docs/))
**DuckDB** to nowoczesny, analityczny system zarządzania bazą danych, niejako "OLAP'owy SQLite". Został zaprojektowany z myślą o maksymalnej wydajności przetwarzania dużych zbiorów danych bezpośrednio w pamięci procesów aplikacji, bez konieczności utrzymywania dedykowanego serwera bazodanowego.

#### Kluczowe cechy z perspektywy hurtowni danych:
* **Architektura Kolumnowa (Column-store):** Podobnie jak klasyczne hurtownie danych (np. Snowflake, Teradata, ClickHouse), DuckDB przechowuje i przetwarza dane kolumnowo, co drastycznie przyspiesza zapytania agregujące i analityczne.
* **Wektorowe Przetwarzanie Zapytań:** Wykorzystuje nowoczesne instrukcje procesora (SIMD) do przetwarzania danych w paczkach (wektorach), minimalizując narzut systemowy.
* **Pełny, Standardowy SQL:** Wspiera zaawansowany SQL, w tym funkcje okna (Window Functions), zapytania zagnieżdżone (CTE) oraz złożone złączenia (JOINs).
* **Wbudowana Integracja z Nowoczesnym Ekosystemem:** Baza natywnie i bezstratnie współpracuje z formatami takimi jak **Parquet, CSV, JSON** oraz technologiami **Arrow, Pandas czy Polars**, pozwalając na odpytywanie plików bezpośrednio, bez konieczności ich wcześniejszego importu (Query-in-Place).
* **Brak Serwera (Serverless/Embedded):** Działa wewnątrz procesu aplikacji (np. skryptu Pythona, aplikacji w dbt czy BI). Nie wymaga instalacji, konfiguracji uprawnień ani zarządzania klastrem.

### 2. MotherDuck ([link do dokumentacji](https://motherduck.com/))
MotherDuck to chmurowa platforma bazodanowa ściśle zintegrowana z DuckDB. Umożliwia hostowanie baz danych w chmurze, bezserwerowe wykonywanie zapytań SQL oraz realizację zapytań hybrydowych (łączących lokalne dane z danymi w chmurze). W projekcie stanowi docelowe środowisko produkcyjne.

### 3. dbt (Data Build Tool) ([link do dokumentacji](https://docs.getdbt.com/))
dbt to framework do zarządzania transformacjami danych wewnątrz bazy danych (warstwa Transform w architekturze ELT). Umożliwia pisanie transformacji w formie parametryzowanych zapytań SQL z wykorzystaniem języka szablonów Jinja. 

W dbt modele danych definiuje się jako niezależne zapytania `SELECT`. System automatycznie generuje skierowany graf acykliczny (DAG), zarządzając kolejnością materializacji obiektów bazy danych na podstawie ich wzajemnych zależności. Projekt wykorzystuje następujące mechanizmy dbt:

- **Modele Inkrementalne:**
  Mechanizm materializacji ładujący do docelowej tabeli jedynie nowe lub zmodyfikowane rekordy z warstwy źródłowej, zamiast wykonywania operacji na pełnym zbiorze (*full refresh*). Optymalizuje to zużycie zasobów i czas wykonywania zapytań przyrostowych.
  
  *Przykład implementacji (`models/marts/constellation/fact_collision.sql`):*
  ```sql
  {{ config(
      materialized='incremental',
      incremental_strategy='append'
  ) }}

  WITH source_data AS (
      select * from {{ ref('int_collisions') }}
  )
  SELECT * FROM source_data
  {% if is_incremental() %}
      WHERE NOT EXISTS (
          SELECT 1 
          FROM {{ this }} AS target_table 
          WHERE source_data.collision_key = target_table.collision_key
      )
  {% endif %}
  ```

- **Testowanie Jakości Danych:**
  System obsługuje automatyczne testowanie poprawności i spójności danych:
  - *Testy generyczne (deklaratywne):* Definiowane w plikach konfiguracyjnych YAML, pozwalające na szybkie asercje takie jak unikalność wartości czy brak wartości NULL.
  - *Testy niestandardowe (singular):* Dedykowane zapytania SQL, które w przypadku wykrycia błędnych wierszy powodują niepowodzenie testu.
  
  *Przykład testu generycznego (`models/marts/constellation/constellation.yml`):*
  ```yaml
  models:
    - name: dim_casualty_profile
      columns:
        - name: casualty_profile_key
          tests:
            - unique
            - not_null
  ```
  
  *Przykład testu niestandardowego (`tests/assert_positive_number_of_vehicles.sql`):*
  ```sql
  select
      collision_index,
      number_of_vehicles
  from {{ ref('fact_collision') }}
  where number_of_vehicles < 1
  ```

- **Separacja środowisk (Targets):**
  Konfiguracja połączeń pozwala na przełączanie baz docelowych bez zmiany logiki modeli transformacji. Uruchomienie komendy dbt z parametrem `--target prod` automatycznie wykonuje transformacje w chmurze (MotherDuck) zamiast w lokalnej bazie.
  
  *Przykład konfiguracji (`~/.dbt/profiles.yml`):*
  ```yaml
  warehouse:
    target: dev
    outputs:
      dev:
        type: duckdb
        path: "/sciezka/do/lokalnego/pliku/stats19.duckdb"
      prod:
        type: duckdb
        path: "md:stats19?motherduck_token=<TWÓJ_TOKEN_MOTHERDUCK>"
  ```

- **Makra:**
  Funkcje i szablony pisane w języku Jinja, ułatwiające ponowne użycie kodu SQL. W projekcie makro jest wykorzystywane m.in. do automatycznego dekodowania identyfikatorów na czytelne etykiety z poziomu słownika.
  
  *Przykład implementacji (`macros/map_ids.sql`):*
  ```sql
  {% macro map_id(table_name, field_name, source_column=none) %}
      {%- if source_column is none -%}
          {%- set source_column = field_name -%}
      {%- endif -%}
      (
          select label 
          from {{ ref('seed_data_guide') }} 
          where "table" = '{{ table_name }}' 
            and "field name" = '{{ field_name }}' 
            and "code/format" = cast({{ source_column }} as varchar)
      )
  {% endmacro %}
  ```

- **Seedy (Seeds):**
  Pliki CSV z danymi referencyjnymi (np. słowniki, mapowania), wersjonowane bezpośrednio w repozytorium Git, które dbt potrafi załadować do bazy danych jako zwykłe tabele i na które można powołać się za pomocą funkcji `ref()`.
  
  *Przykład zawartości pliku słownika (`seeds/dft_data_guide/seed_data_guide.csv`):*
  ```csv
  table,field name,code/format,label,note
  collision,police_force,1,Metropolitan Police,
  collision,police_force,3,Cumbria,
  collision,collision_severity,1,Fatal,
  ```

### 4. Lightdash ([link do dokumentacji](https://docs.lightdash.com/))
Lightdash to platforma Business Intelligence natywnie zintegrowana z dbt. Umożliwia definiowanie metryk i wymiarów analitycznych bezpośrednio w plikach konfiguracyjnych YAML warstwy semantycznej projektu dbt. Definicje te stanowią wspólne źródło prawdy, na podstawie których narzędzie dynamicznie generuje zapytania SQL odpowiedzialne za renderowanie elementów interfejsu wizualnego.

## Główne zalety stosu technologicznego
1. **Deklaratywność i wersjonowanie:** Schemat bazy, reguły transformacji oraz definicje raportów są w całości opisane w kodzie i wersjonowane w systemie Git.
2. **Szeroka gama funkcji DuckDB:** DuckDB oferuje wiele przydatnych funkcji, miedzy innymi webowy interfejs do przeglądania i wykonywania zapytań SQL oraz możliwość bezpośredniego odczytu plików csv z dysku lokalnego. Jako że sama baza jest de facto plikiem na dysku jest ona niezwykle prosta w obsłudze.
3. **Łatwe zarządzanie materializacją modeli:** dbt umożliwia proste defniowanie i zmianę sposobu materializacji modeli. Każdy model moży być zmaterializowany jako tabela (table), widok (view), widok zmaterializowany (materialized view) lub model przyrostowy (incremental) pozwalający na definiowanie sposobu wstawiania nowych danych.
4. **Testowanie danych:** dbt pozwala na definiowanie zcentralizowanych testów (generycznych oraz niestandardowych, opartych o zapytania SQL) uruchamianych przy transformacjach.
5. **Seed'y oraz makra:** Obecne w dbt seed'y (wersjonowane pliki csv z danymi) oraz makra (wielokrotnie wykorzystywany kod SQL) znacznie ułatwiają tworzenie transformacji.
6. **Automatycznie generowana dokumentacja:** dbt pozwala na generowanie dokumentacji na podstawie kodu i konfiguracji w plikach projektu. Automatycznie generowany widok grafu zależności modeli (DAG), jasno przedstawia przepływ danych w projekcie.

## Instrukcja lokalnego uruchomienia

### 1. Przygotowanie środowiska Python
Projekt zarządza zależnościami za pomocą `pyproject.toml`. Należy utworzyć środowisko wirtualne i zainstalować wymagane pakiety:

```bash
# Utworzenie i aktywacja środowiska wirtualnego
python -m venv .venv
source .venv/bin/activate

# Instalacja pakietów zdefiniowanych w projekcie
pip install .
```

### 2. Pobranie danych źródłowych
Dane wejściowe pochodzą z oficjalnego portalu brytyjskiego UK Road Safety Open Data ([link do portalu](https://www.gov.uk/government/statistical-data-sets/road-safety-open-data)).
Należy pobrać odpowiednie pliki CSV (wypadki/collisions, pojazdy/vehicles, ofiary/casualties) i umieścić je w katalogu `~/data/dft-incremental/`. Wzorce nazw plików to:
- `dft-road-casualty-statistics-collision-*.csv`
- `dft-road-casualty-statistics-casualty-*.csv`
- `dft-road-casualty-statistics-vehicle-*.csv`

*(Uwaga: Podane tu wartości są moimi własnymi domyślnymi ścieżkami. Można je dostosować w pliku konfiguracyjnym `dbt_project/models/staging/src_stats19.yml`)*.

### 3. Przygotowanie dbt
Przejdź do katalogu projektu dbt i pobierz pakiety zewnętrzne (np. dbt-utils):

```bash
cd dbt_project
dbt deps
```

Konfiguracja połączenia z bazą danych znajduje się w pliku `~/.dbt/profiles.yml`. Należy utworzyć w nim profil o nazwie `warehouse`. 

Środowisko produkcyjne (`prod` korzystające z MotherDuck) jest opcjonalne – do lokalnego uruchomienia wystarczy konfiguracja środowiska deweloperskiego (`dev`).

Przykładowy szablon pliku `profiles.yml`:

```yaml
warehouse:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: "/sciezka/do/lokalnego/pliku/stats19.duckdb"
      schema: main
      threads: 2
    
    # Konfiguracja opcjonalna
    prod:
      type: duckdb
      path: "md:stats19?motherduck_token=<TWÓJ_TOKEN_MOTHERDUCK>"
      schema: main
      threads: 4
```


### 4. Wykonanie potoku transformacji i testów
W celu uruchomienia całego procesu przetwarzania danych (budowy tabel i widoków) oraz automatycznego wykonania testów jakości danych, należy wywołać:

```bash
# Uruchomienie lokalne (DuckDB)
dbt build

# Uruchomienie produkcyjne (MotherDuck)
dbt build --target prod
```

## Załącznik: Schemat Modelu Wielowymiarowego

Poniższy diagram przedstawia strukturę logiczną konstelacji faktów (tabele faktów oraz współdzielone tabele wymiarów) zaimplementowaną w warstwie `marts/constellation/`:

![Model danych - Konstelacja](diagrams/constellation.png)
