USE agence_immo;

DELIMITER //

CREATE PROCEDURE prospects_par_ville(IN ville_recherche VARCHAR(100))
BEGIN
    SELECT 
        nom, 
        prenom, 
        budget_max, 
        nb_interactions, 
        nb_biens_vus
    FROM vue_scoring_prospects
    WHERE ville = ville_recherche
    ORDER BY nb_interactions DESC;
END //

DELIMITER ;
