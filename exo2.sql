-- Question 1 :
EXPLAIN ANALYZE
SELECT * FROM title_basics WHERE start_year = 1950 AND title_type = 'movie';

-- Question 2 :
-- 1. La stratégie utilisée pour le filtre sur start_year est un Bitmap Index Scan (si l'index simple existe), sinon un Seq Scan.
-- 2. Le filtre sur title_type est appliqué après le filtre sur start_year, lors du Bitmap Heap Scan ou du Seq Scan.
-- 3. Le nombre de lignes passant le premier filtre (start_year = 1950) dépend du nombre de films sortis cette année-là ; le second filtre (title_type = 'movie') réduit encore ce nombre.
-- 4. Limitation de l'index actuel : il ne porte que sur start_year, donc PostgreSQL doit encore filtrer sur title_type après avoir trouvé les lignes de l'année 1950.

-- Question 3 :
CREATE INDEX idx_title_basics_year_type ON title_basics(start_year, title_type);

-- Question 4 :
EXPLAIN ANALYZE
SELECT * FROM title_basics WHERE start_year = 1950 AND title_type = 'movie';
-- Après création de l'index composite, PostgreSQL peut utiliser un Bitmap Index Scan ou un Index Scan sur les deux colonnes, rendant le filtrage plus efficace.

-- Question 5 :
EXPLAIN ANALYZE
SELECT tconst, primary_title, start_year, title_type
FROM title_basics
WHERE start_year = 1950 AND title_type = 'movie';
-- 1. Oui, il est généralement plus rapide car moins de colonnes sont lues et transférées.
-- 2. Elle est efficace, mais l'index composite apporte déjà un gain majeur. La réduction du nombre de colonnes optimise surtout l'I/O et le transfert, mais moins que le passage d'un scan séquentiel à un scan par index.
-- 3. Si l'index composite inclut toutes les colonnes de la requête (tconst, primary_title, start_year, title_type), PostgreSQL peut répondre à la requête uniquement à partir de l'index, sans accéder à la table (Heap Only Scan), ce qui maximise la performance.

-- Question 6 :
-- 1. Le temps d'exécution est significativement réduit grâce à l'index composite (souvent divisé par 5 à 10 selon la sélectivité).
-- 2. Il permet à PostgreSQL d'utiliser un Index Scan ou Bitmap Index Scan sur les deux colonnes, rendant le filtrage beaucoup plus sélectif et rapide.
-- 3. Parce que l'index composite permet de cibler précisément les lignes à lire, évitant de parcourir des blocs inutiles.
-- 4. Quand la requête filtre sur plusieurs colonnes dans l'ordre de l'index, surtout si ces colonnes sont très sélectives (peu de lignes correspondent à la combinaison des valeurs filtrées).
