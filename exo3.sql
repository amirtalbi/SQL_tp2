-- Question 1 :
EXPLAIN ANALYZE
SELECT b.primary_title, r.average_rating
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.start_year = 1994
  AND b.title_type = 'movie'
  AND r.average_rating > 8.5;

-- Question 2 :
-- 1. L'algorithme de jointure utilisé est généralement un Hash Join ou un Merge Join, selon la taille des tables et les index disponibles.
-- 2. L'index sur start_year est utilisé pour filtrer rapidement les films de 1994 dans title_basics.
-- 3. La condition sur average_rating (> 8.5) est appliquée lors du scan ou du filtrage sur la table title_ratings, éventuellement en utilisant un index si disponible.
-- 4. PostgreSQL utilise le parallélisme pour accélérer le traitement sur de grandes tables, en répartissant le travail entre plusieurs workers.

-- Question 3 :
CREATE INDEX idx_title_ratings_average_rating ON title_ratings(average_rating);

-- Question 4 :
EXPLAIN ANALYZE
SELECT b.primary_title, r.average_rating
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.start_year = 1994
  AND b.title_type = 'movie'
  AND r.average_rating > 8.5;
-- Après création de l'index, PostgreSQL peut utiliser un Index Scan ou un Bitmap Index Scan sur average_rating pour accélérer le filtrage.

-- Question 5 :
-- 1. Il peut passer d'un Hash Join à un Merge Join ou Nested Loop Join si les index rendent la jointure plus efficace.
-- 2. Il permet de filtrer rapidement les lignes de title_ratings ayant une note > 8.5, réduisant le nombre de lignes à joindre.
-- 3. Oui, car moins de lignes sont lues et jointes grâce à l'index, ce qui réduit le coût global de la requête.
-- 4. Si le nombre de lignes à traiter devient faible après filtrage par index, le coût de gestion du parallélisme dépasse le gain, donc PostgreSQL préfère un plan séquentiel plus simple.
