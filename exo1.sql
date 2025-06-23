-- Question 1 :
EXPLAIN ANALYZE
SELECT * FROM title_basics WHERE start_year = 2020;

-- Question 2 :
-- 1. Pourquoi PostgreSQL utilise-t-il un Parallel Sequential Scan ?
-- Parce qu'on n'a pas d'index sur la colonne 'start_year', et que la requête doit parcourir toute la table pour trouver les lignes où start_year = 2020. Le scan séquentiel parallèle permet d'accélérer ce parcours en utilisant plusieurs workers.

-- 2. La parallélisation est-elle justifiée ici ? Pourquoi ?
-- Oui, car la table est volumineuse. La parallélisation permet de répartir la charge entre plusieurs cœurs du processeur et de réduire le temps du scan global.

-- 3. Que représente la valeur "Rows Removed by Filter" ?
-- C'est le nombre de lignes lues dans la table qui ne correspondent pas à la condition WHERE (start_year = 2020) et qui sont donc rejetées après lecture.

-- Question 3 :
CREATE INDEX idx_title_basics_start_year ON title_basics(start_year);

-- Question 4 :
-- L'index a permis de diviser le temps d'exécution est passé de 1172 ms à 190 ms. 
-- La stratégie de scan est passée d'un scan séquentiel total à un scan par index beaucoup plus sélectif. 
-- Le nombre de lignes relues et rejetées a diminué.

-- Question 5 :
EXPLAIN ANALYZE
SELECT tconst, primary_title, start_year 
FROM title_basics 
WHERE start_year = 2020;

-- 1. Oui, le temps d'exécution est plus rapide avec la sélection de colonnes spécifiques.
--    La requête optimisée ne doit lire et transférer que 3 colonnes au lieu des 9 colonnes de la table,
--    ce qui réduit significativement la quantité de données à traiter et à transférer.
--
-- 2. Le plan d'exécution utilise toujours un Bitmap Index Scan suivi d'un Bitmap Heap Scan,
--    mais la quantité de données lues en mémoire est moindre car seules 3 colonnes sont accédées
--    au lieu de toutes les colonnes de la table.
--
-- 3. Pour plusieurs raisons :
--    - Moins de données à lire depuis le disque (I/O réduit)
--    - Moins de mémoire utilisée pour stocker les résultats
--    - Moins de données à transférer entre PostgreSQL et le client
--    - Meilleure utilisation du cache CPU car les données sont plus compactes
--    Cette optimisation est particulièrement efficace sur les tables larges avec beaucoup de colonnes. 

-- Question 6 :
-- 1. PostgreSQL utilise maintenant un Bitmap Index Scan sur l'index créé, suivi d'un Bitmap Heap Scan pour accéder aux lignes correspondantes dans la table.
--
-- 2. Oui, le temps d'exécution est passé d'environ 1172 ms (scan séquentiel) à environ 190 ms (scan par index), soit une amélioration d'environ 6 fois.
--
-- 3. Bitmap Index Scan : PostgreSQL parcourt l'index pour trouver les références (adresses) des lignes qui satisfont la condition (ici, start_year = 2020) et construit une bitmap (tableau binaire) de ces adresses.
-- Bitmap Heap Scan : PostgreSQL utilise ensuite cette bitmap pour accéder efficacement aux blocs de la table (heap) qui contiennent les lignes recherchées, en évitant de lire les blocs inutiles.
--
-- 4. Parce que même avec l'index, il y a encore beaucoup de lignes à lire (plus de 84 résultats, mais beaucoup de blocs à consulter). L'index permet de cibler les lignes, mais si la valeur recherchée (2020) est fréquente, il y a encore beaucoup d'accès disque et de vérifications à faire. L'amélioration serait plus spectaculaire si la requête était plus sélective (valeur rare) ou si la table avait moins de colonnes volumineuses.

