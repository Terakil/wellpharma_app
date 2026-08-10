-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 06 août 2026 à 17:40
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `pharmacie_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `produits`
--

CREATE TABLE `produits` (
  `id_produit` int(11) NOT NULL AUTO_INCREMENT,
  `designation` varchar(255) NOT NULL,
  `reference` varchar(50) NOT NULL,
  `categorie` varchar(100) DEFAULT NULL,
  `quantite` int(11) NOT NULL CHECK (`quantite` >= 0),
  `prix_unitaire` decimal(10,2) NOT NULL CHECK (`prix_unitaire` >= 0),
  `statut` enum('EN STOCK','FAIBLE','RUPTURE') DEFAULT 'EN STOCK',
  `description` text DEFAULT NULL,
  `image_url` text DEFAULT NULL,
  `needs_prescription` tinyint(1) NOT NULL DEFAULT 0,
  `date_ajout` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_produit`),
  UNIQUE KEY `reference` (`reference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `produits`
--

INSERT INTO `produits` (`designation`, `reference`, `categorie`, `quantite`, `prix_unitaire`, `statut`, `description`, `image_url`, `needs_prescription`) VALUES
('Paracétamole', 'REF-PARA-01', 'Antalgique', 120, 500.00, 'EN STOCK', 'Contre la douleur et la fièvre.', 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500', 0),
('Doliprane 1000mg', 'REF-DOLI-01', 'Antalgique', 80, 2000.00, 'EN STOCK', 'Paracétamol fortement dosé.', 'https://images.unsplash.com/photo-1550573105-df27ef279313?w=500', 0),
('Amoxicilline', 'REF-AMOX-01', 'Antibiotique', 45, 1500.00, 'FAIBLE', 'Antibiotique large spectre.', 'https://images.unsplash.com/photo-1576073719710-4109405d431c?w=500', 1),
('Sirop Antitussif', 'REF-SIRO-01', 'Antitussif', 30, 7500.00, 'FAIBLE', 'Calme la toux sèche.', 'https://images.unsplash.com/photo-1512069772995-ec65ed45afd6?w=500', 0),
('Vitamine C 500mg', 'REF-VITA-01', 'Vitamines', 200, 3000.00, 'EN STOCK', 'Renforce le système immunitaire.', 'https://images.unsplash.com/photo-1616671285421-081f21136511?w=500', 0),
('Co-Arthemet', 'REF-Palu-01', 'Antipaludique', 10, 12000.00, 'RUPTURE', 'Traitement contre le paludisme.', 'https://images.unsplash.com/photo-1587854692152-cbe660dbbb88?w=500', 1),
('Augmentin 1g', 'REF-AUG-01', 'Antibiotique', 50, 45000.00, 'EN STOCK', 'Amoxicilline + Acide Clavulanique.', 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=500', 1);

-- --------------------------------------------------------

--
-- Structure de la table `alertes`
--

CREATE TABLE `alertes` (
  `id_alerte` int(11) NOT NULL AUTO_INCREMENT,
  `id_produit` int(11) NOT NULL,
  `type_alerte` enum('Stock faible','Rupture') NOT NULL,
  `message` varchar(255) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_alerte`),
  KEY `id_produit` (`id_produit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `commandes`
--

CREATE TABLE `commandes` (
  `id_commande` int(11) NOT NULL AUTO_INCREMENT,
  `id_produit` int(11) NOT NULL,
  `quantite` int(11) NOT NULL CHECK (`quantite` > 0),
  `prix_total` decimal(15,2) NOT NULL,
  `acheteur` varchar(100) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_commande`),
  KEY `id_produit` (`id_produit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `historique`
--

CREATE TABLE `historique` (
  `id_historique` int(11) NOT NULL AUTO_INCREMENT,
  `action` enum('Ajout','Suppression','Mise à jour') NOT NULL,
  `produit` varchar(255) NOT NULL,
  `utilisateur` varchar(100) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_historique`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `stats_globales`
--

CREATE TABLE `stats_globales` (
  `id_stat` int(11) NOT NULL AUTO_INCREMENT,
  `total_references` int(11) DEFAULT NULL,
  `valeur_stock` decimal(15,2) DEFAULT NULL,
  `alertes_stock` int(11) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_stat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `utilisateurs`
--

CREATE TABLE `utilisateurs` (
  `id_utilisateur` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) NOT NULL,
  `role` enum('admin','user','pharmacien','docteur') NOT NULL DEFAULT 'user',
  `email` varchar(150) NOT NULL,
  `motdepasse` varchar(255) NOT NULL,
  PRIMARY KEY (`id_utilisateur`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `utilisateurs`
--

INSERT INTO `utilisateurs` (`nom`, `role`, `email`, `motdepasse`) VALUES
('Pharmacien Chef', 'admin', 'admin@wellpharma.com', 'admin123'),
('Client Test', 'user', 'client@test.com', 'user123');

--
-- Contraintes pour les tables déchargées
--

ALTER TABLE `alertes`
  ADD CONSTRAINT `alertes_ibfk_1` FOREIGN KEY (`id_produit`) REFERENCES `produits` (`id_produit`);

ALTER TABLE `commandes`
  ADD CONSTRAINT `commandes_ibfk_1` FOREIGN KEY (`id_produit`) REFERENCES `produits` (`id_produit`);

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
