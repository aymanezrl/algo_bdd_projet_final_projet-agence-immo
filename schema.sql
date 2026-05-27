-- ============================================
-- CRÉATION DE LA BASE DE DONNÉES
-- ============================================
CREATE DATABASE IF NOT EXISTS agence_immo;
USE agence_immo;

-- ============================================
-- TABLE 1 : prospects
-- ============================================
CREATE TABLE prospects (
    id_prospect INT AUTO_INCREMENT PRIMARY KEY,
    nom         VARCHAR(100) NOT NULL,
    prenom      VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    telephone   VARCHAR(20),
    ville       VARCHAR(100) NOT NULL,
    budget_max  DECIMAL(10,2) NOT NULL,
    date_contact DATE NOT NULL
);

-- ============================================
-- TABLE 2 : biens
-- ============================================
CREATE TABLE biens (
    id_bien      INT AUTO_INCREMENT PRIMARY KEY,
    titre        VARCHAR(150) NOT NULL,
    type_bien    ENUM('appartement', 'maison') NOT NULL,
    ville        VARCHAR(100) NOT NULL,
    prix         DECIMAL(10,2) NOT NULL,
    surface_m2   INT NOT NULL,
    nb_pieces    INT NOT NULL,
    disponible   BOOLEAN DEFAULT TRUE
);

-- ============================================
-- TABLE 3 : interactions
-- ============================================
CREATE TABLE interactions (
    id_interaction  INT AUTO_INCREMENT PRIMARY KEY,
    id_prospect     INT NOT NULL,
    type_action     ENUM('visite', 'appel', 'email', 'offre') NOT NULL,
    date_action     DATE NOT NULL,
    commentaire     VARCHAR(255),
    FOREIGN KEY (id_prospect) REFERENCES prospects(id_prospect)
);

-- ============================================
-- TABLE 4 : prospects_biens (many-to-many)
-- ============================================
CREATE TABLE prospects_biens (
    id_prospect INT NOT NULL,
    id_bien     INT NOT NULL,
    date_interet DATE NOT NULL,
    PRIMARY KEY (id_prospect, id_bien),
    FOREIGN KEY (id_prospect) REFERENCES prospects(id_prospect),
    FOREIGN KEY (id_bien)     REFERENCES biens(id_bien)
);

-- ============================================
-- INSERTION DES DONNÉES : prospects (35 lignes)
-- ============================================
INSERT INTO prospects (nom, prenom, email, telephone, ville, budget_max, date_contact) VALUES
('Martin', 'Sophie', 'sophie.martin@gmail.com', '0601020304', 'Lyon', 320000, '2024-01-05'),
('Bernard', 'Lucas', 'lucas.bernard@gmail.com', '0602030405', 'Lyon', 250000, '2024-01-08'),
('Dubois', 'Emma', 'emma.dubois@yahoo.fr', '0603040506', 'Villeurbanne', 180000, '2024-01-12'),
('Thomas', 'Hugo', 'hugo.thomas@hotmail.fr', '0604050607', 'Lyon', 400000, '2024-01-15'),
('Petit', 'Léa', 'lea.petit@gmail.com', '0605060708', 'Caluire', 210000, '2024-01-18'),
('Robert', 'Nathan', 'nathan.robert@gmail.com', '0606070809', 'Lyon', 295000, '2024-01-20'),
('Richard', 'Camille', 'camille.richard@gmail.com', '0607080910', 'Villeurbanne', 230000, '2024-01-22'),
('Leroy', 'Théo', 'theo.leroy@yahoo.fr', '0608091011', 'Lyon', 350000, '2024-02-01'),
('Moreau', 'Inès', 'ines.moreau@gmail.com', '0609101112', 'Écully', 270000, '2024-02-03'),
('Simon', 'Tom', 'tom.simon@gmail.com', '0610111213', 'Lyon', 190000, '2024-02-06'),
('Laurent', 'Jade', 'jade.laurent@hotmail.fr', '0611121314', 'Lyon', 310000, '2024-02-10'),
('Lefebvre', 'Alexis', 'alexis.lefebvre@gmail.com', '0612131415', 'Bron', 225000, '2024-02-14'),
('Michel', 'Chloé', 'chloe.michel@yahoo.fr', '0613141516', 'Lyon', 280000, '2024-02-17'),
('Garcia', 'Antoine', 'antoine.garcia@gmail.com', '0614151617', 'Caluire', 195000, '2024-02-20'),
('David', 'Manon', 'manon.david@gmail.com', '0615161718', 'Lyon', 420000, '2024-02-22'),
('Bertrand', 'Romain', 'romain.bertrand@gmail.com', '0616171819', 'Villeurbanne', 240000, '2024-03-01'),
('Roux', 'Sarah', 'sarah.roux@hotmail.fr', '0617181920', 'Lyon', 360000, '2024-03-04'),
('Vincent', 'Kevin', 'kevin.vincent@gmail.com', '0618192021', 'Écully', 215000, '2024-03-07'),
('Fournier', 'Julie', 'julie.fournier@gmail.com', '0619202122', 'Lyon', 290000, '2024-03-10'),
('Morel', 'Pierre', 'pierre.morel@yahoo.fr', '0620212223', 'Bron', 175000, '2024-03-13'),
('Girard', 'Alice', 'alice.girard@gmail.com', '0621222324', 'Lyon', 335000, '2024-03-16'),
('André', 'Maxime', 'maxime.andre@gmail.com', '0622232425', 'Caluire', 260000, '2024-03-19'),
('Lefevre', 'Clara', 'clara.lefevre@hotmail.fr', '0623242526', 'Lyon', 385000, '2024-03-22'),
('Mercier', 'Baptiste', 'baptiste.mercier@gmail.com', '0624252627', 'Villeurbanne', 205000, '2024-04-01'),
('Dupont', 'Elisa', 'elisa.dupont@gmail.com', '0625262728', 'Lyon', 445000, '2024-04-04'),
('Lambert', 'Nicolas', 'nicolas.lambert@yahoo.fr', '0626272829', 'Écully', 315000, '2024-04-07'),
('Bonnet', 'Laura', 'laura.bonnet@gmail.com', '0627282930', 'Lyon', 270000, '2024-04-10'),
('François', 'Julien', 'julien.francois@gmail.com', '0628293031', 'Bron', 185000, '2024-04-13'),
('Martinez', 'Anaïs', 'anais.martinez@hotmail.fr', '0629303132', 'Lyon', 395000, '2024-04-16'),
('Jacobs', 'Florian', 'florian.jacobs@gmail.com', '0630313233', 'Caluire', 245000, '2024-04-19'),
('Blanc', 'Pauline', 'pauline.blanc@gmail.com', '0631323334', 'Lyon', 300000, '2024-04-22'),
('Garnier', 'Clément', 'clement.garnier@yahoo.fr', '0632333435', 'Villeurbanne', 220000, '2024-05-01'),
('Chevalier', 'Marion', 'marion.chevalier@gmail.com', '0633343536', 'Lyon', 375000, '2024-05-04'),
('Robin', 'Thomas', 'thomas.robin@gmail.com', '0634353637', 'Écully', 255000, '2024-05-07'),
('Muller', 'Océane', 'oceane.muller@hotmail.fr', '0635363738', 'Lyon', 430000, '2024-05-10');

-- ============================================
-- INSERTION DES DONNÉES : biens (35 lignes)
-- ============================================
INSERT INTO biens (titre, type_bien, ville, prix, surface_m2, nb_pieces, disponible) VALUES
('Bel appart T3 centre Lyon', 'appartement', 'Lyon', 310000, 68, 3, TRUE),
('Maison avec jardin Caluire', 'maison', 'Caluire', 385000, 110, 5, TRUE),
('Studio rénové Villeurbanne', 'appartement', 'Villeurbanne', 145000, 28, 1, TRUE),
('T4 lumineux Lyon 6e', 'appartement', 'Lyon', 420000, 92, 4, TRUE),
('Maison 4 pièces Écully', 'maison', 'Écully', 370000, 105, 4, TRUE),
('T2 moderne Lyon 3e', 'appartement', 'Lyon', 195000, 45, 2, TRUE),
('Grande maison Bron', 'maison', 'Bron', 290000, 130, 6, TRUE),
('T3 calme Villeurbanne', 'appartement', 'Villeurbanne', 225000, 65, 3, TRUE),
('Appartement vue dégagée Lyon 8e', 'appartement', 'Lyon', 275000, 72, 3, TRUE),
('Maison contemporaine Caluire', 'maison', 'Caluire', 455000, 145, 5, TRUE),
('T2 proche métro Lyon 4e', 'appartement', 'Lyon', 185000, 42, 2, TRUE),
('Maison de ville Écully', 'maison', 'Écully', 340000, 98, 4, TRUE),
('T5 familial Lyon 7e', 'appartement', 'Lyon', 395000, 105, 5, TRUE),
('Studio neuf Bron', 'appartement', 'Bron', 135000, 25, 1, TRUE),
('Maison rénovée Villeurbanne', 'maison', 'Villeurbanne', 315000, 115, 5, TRUE),
('T3 avec balcon Lyon 5e', 'appartement', 'Lyon', 255000, 70, 3, TRUE),
('Maison plain-pied Caluire', 'maison', 'Caluire', 410000, 120, 4, TRUE),
('T4 terrasse Lyon 2e', 'appartement', 'Lyon', 365000, 88, 4, TRUE),
('Studio étudiant Villeurbanne', 'appartement', 'Villeurbanne', 125000, 22, 1, TRUE),
('Maison avec piscine Écully', 'maison', 'Écully', 520000, 180, 6, FALSE),
('T2 rénové Lyon 1er', 'appartement', 'Lyon', 210000, 48, 2, TRUE),
('Maison familiale Bron', 'maison', 'Bron', 265000, 125, 5, TRUE),
('T3 neuf Lyon 9e', 'appartement', 'Lyon', 285000, 67, 3, TRUE),
('Appartement standing Lyon 6e', 'appartement', 'Lyon', 480000, 115, 4, FALSE),
('Maison ancienne rénovée Caluire', 'maison', 'Caluire', 375000, 135, 5, TRUE),
('T2 investissement Villeurbanne', 'appartement', 'Villeurbanne', 165000, 40, 2, TRUE),
('Grande maison Écully', 'maison', 'Écully', 490000, 160, 6, TRUE),
('T4 calme Lyon 8e', 'appartement', 'Lyon', 345000, 90, 4, TRUE),
('Maison moderne Bron', 'maison', 'Bron', 310000, 118, 4, TRUE),
('T3 lumineux Lyon 3e', 'appartement', 'Lyon', 265000, 71, 3, TRUE),
('Studio centre Villeurbanne', 'appartement', 'Villeurbanne', 138000, 26, 1, TRUE),
('Maison avec garage Caluire', 'maison', 'Caluire', 398000, 128, 5, TRUE),
('T5 duplex Lyon 7e', 'appartement', 'Lyon', 435000, 118, 5, TRUE),
('Maison plain-pied Bron', 'maison', 'Bron', 278000, 112, 4, TRUE),
('T2 balcon Lyon 4e', 'appartement', 'Lyon', 198000, 46, 2, TRUE);

-- ============================================
-- INSERTION DES DONNÉES : interactions (40 lignes)
-- ============================================
INSERT INTO interactions (id_prospect, type_action, date_action, commentaire) VALUES
(1, 'appel', '2024-01-06', 'Premier contact, très intéressé'),
(1, 'visite', '2024-01-20', 'Visite bien n°1, retour positif'),
(1, 'offre', '2024-02-01', 'Offre déposée à 300000€'),
(2, 'email', '2024-01-09', 'Envoi de brochures'),
(2, 'appel', '2024-01-15', 'Rappel suite email'),
(3, 'appel', '2024-01-13', 'Recherche studio ou T2'),
(4, 'visite', '2024-01-18', 'Visite bien n°4, intéressé'),
(4, 'visite', '2024-01-25', 'Deuxième visite bien n°4'),
(4, 'offre', '2024-02-05', 'Offre à 410000€'),
(5, 'email', '2024-01-19', 'Demande infos complémentaires'),
(6, 'appel', '2024-01-21', 'Cherche T3 Lyon ou Villeurbanne'),
(6, 'visite', '2024-02-05', 'Visite bien n°9'),
(7, 'email', '2024-01-23', 'Intéressée par Villeurbanne'),
(8, 'appel', '2024-02-02', 'Budget flexible, veut maison'),
(8, 'visite', '2024-02-15', 'Visite bien n°2'),
(8, 'visite', '2024-02-22', 'Visite bien n°5'),
(8, 'offre', '2024-03-01', 'Offre à 360000€'),
(9, 'email', '2024-02-04', 'Demande visite Écully'),
(9, 'visite', '2024-02-18', 'Visite bien n°5'),
(10, 'appel', '2024-02-07', 'Petit budget, cherche studio'),
(11, 'visite', '2024-02-12', 'Visite bien n°1'),
(11, 'visite', '2024-02-19', 'Visite bien n°16'),
(12, 'email', '2024-02-15', 'Intéressé par Bron'),
(13, 'appel', '2024-02-18', 'Cherche T3 avec balcon'),
(13, 'visite', '2024-03-01', 'Visite bien n°16'),
(14, 'email', '2024-02-21', 'Premier contact par formulaire'),
(15, 'visite', '2024-02-25', 'Visite bien n°10'),
(15, 'visite', '2024-03-04', 'Visite bien n°17'),
(15, 'offre', '2024-03-15', 'Offre à 440000€'),
(16, 'appel', '2024-03-02', 'Cherche T3 Villeurbanne'),
(17, 'visite', '2024-03-06', 'Visite bien n°13'),
(18, 'email', '2024-03-08', 'Demande infos Écully'),
(19, 'appel', '2024-03-11', 'Intéressée par Lyon 7e'),
(20, 'email', '2024-03-14', 'Budget serré, cherche studio Bron'),
(21, 'visite', '2024-03-18', 'Visite bien n°1'),
(21, 'visite', '2024-03-25', 'Visite bien n°23'),
(22, 'appel', '2024-03-20', 'Cherche T3 ou T4 Caluire'),
(23, 'visite', '2024-03-24', 'Visite bien n°4'),
(25, 'visite', '2024-04-06', 'Visite bien n°24'),
(25, 'offre', '2024-04-20', 'Offre à 460000€');

-- ============================================
-- INSERTION DES DONNÉES : prospects_biens (35 lignes)
-- ============================================
INSERT INTO prospects_biens (id_prospect, id_bien, date_interet) VALUES
(1, 1, '2024-01-20'),
(1, 9, '2024-01-22'),
(2, 6, '2024-01-15'),
(2, 11, '2024-01-16'),
(3, 3, '2024-01-13'),
(3, 19, '2024-01-14'),
(4, 4, '2024-01-18'),
(4, 13, '2024-01-26'),
(5, 6, '2024-01-19'),
(5, 11, '2024-01-20'),
(6, 8, '2024-02-05'),
(6, 9, '2024-02-06'),
(7, 8, '2024-01-23'),
(7, 3, '2024-01-24'),
(8, 2, '2024-02-15'),
(8, 5, '2024-02-22'),
(8, 17, '2024-02-28'),
(9, 5, '2024-02-18'),
(9, 12, '2024-02-19'),
(10, 3, '2024-02-07'),
(10, 14, '2024-02-08'),
(11, 1, '2024-02-12'),
(11, 16, '2024-02-19'),
(12, 7, '2024-02-15'),
(13, 16, '2024-03-01'),
(13, 23, '2024-03-02'),
(14, 6, '2024-02-21'),
(15, 10, '2024-02-25'),
(15, 17, '2024-03-04'),
(16, 8, '2024-03-02'),
(17, 13, '2024-03-06'),
(18, 12, '2024-03-08'),
(21, 1, '2024-03-18'),
(21, 23, '2024-03-25'),
(25, 24, '2024-04-06');