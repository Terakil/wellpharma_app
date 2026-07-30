-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 26 mars 2026 à 21:31
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `pharmacie`
--

-- --------------------------------------------------------

--
-- Structure de la table `alertes`
--

CREATE TABLE `alertes` (
  `id_alerte` int(11) NOT NULL,
  `id_produit` int(11) NOT NULL,
  `type_alerte` enum('Stock faible','Rupture') NOT NULL,
  `message` varchar(255) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `commandes`
--

CREATE TABLE `commandes` (
  `id_commande` int(11) NOT NULL,
  `id_produit` int(11) NOT NULL,
  `quantite` int(11) NOT NULL CHECK (`quantite` > 0),
  `prix_total` decimal(15,2) NOT NULL,
  `acheteur` varchar(100) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `historique`
--

CREATE TABLE `historique` (
  `id_historique` int(11) NOT NULL,
  `action` enum('Ajout','Suppression','Mise à jour') NOT NULL,
  `produit` varchar(255) NOT NULL,
  `utilisateur` varchar(100) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `produits`
--

CREATE TABLE `produits` (
  `id_produit` int(11) NOT NULL,
  `designation` varchar(255) NOT NULL,
  `reference` varchar(50) NOT NULL,
  `categorie` varchar(100) DEFAULT NULL,
  `quantite` int(11) NOT NULL CHECK (`quantite` >= 0),
  `prix_unitaire` decimal(10,2) NOT NULL CHECK (`prix_unitaire` >= 0),
  `statut` enum('EN STOCK','FAIBLE','RUPTURE') DEFAULT 'EN STOCK',
  `description` text DEFAULT NULL,
  `date_ajout` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `produits`
--

INSERT INTO `produits` (`id_produit`, `designation`, `reference`, `categorie`, `quantite`, `prix_unitaire`, `statut`, `description`, `date_ajout`) VALUES
(1, 'Paracétamole', '54654f', 'Antibiotique', 100, 6000.00, 'EN STOCK', 'sdqfghfdsq', '2026-03-22 12:20:12'),
(2, 'Doliprane', 'REF-5178', 'Antitussif', 100, 6000.00, 'EN STOCK', 'uytzertyreqzrtyhfgds', '2026-03-22 12:42:46'),
(3, 'Omeprazolr', '', 'Antibiotique', 100, 6000.00, 'EN STOCK', 'suc gastrique', '2026-03-23 18:21:23'),
(10, 'Doliprane', 'REF-10', 'Antitussif', 100, 5200.00, 'EN STOCK', 'sdfghnbgfvcd', '2026-03-23 19:35:25'),
(11, 'Omeprazole', 'REF-11', 'Antipaludique', 200, 6000.00, 'EN STOCK', 'azertyhj', '2026-03-25 07:23:44');

-- --------------------------------------------------------

--
-- Structure de la table `stats_globales`
--

CREATE TABLE `stats_globales` (
  `id_stat` int(11) NOT NULL,
  `total_references` int(11) DEFAULT NULL,
  `valeur_stock` decimal(15,2) DEFAULT NULL,
  `alertes_stock` int(11) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `utilisateurs`
--

CREATE TABLE `utilisateurs` (
  `id_utilisateur` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `role` enum('admin','pharmacien','docteur') NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `motdepasse` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `alertes`
--
ALTER TABLE `alertes`
  ADD PRIMARY KEY (`id_alerte`),
  ADD KEY `id_produit` (`id_produit`);

--
-- Index pour la table `commandes`
--
ALTER TABLE `commandes`
  ADD PRIMARY KEY (`id_commande`),
  ADD KEY `id_produit` (`id_produit`);

--
-- Index pour la table `historique`
--
ALTER TABLE `historique`
  ADD PRIMARY KEY (`id_historique`);

--
-- Index pour la table `produits`
--
ALTER TABLE `produits`
  ADD PRIMARY KEY (`id_produit`),
  ADD UNIQUE KEY `reference` (`reference`);

--
-- Index pour la table `stats_globales`
--
ALTER TABLE `stats_globales`
  ADD PRIMARY KEY (`id_stat`);

--
-- Index pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD PRIMARY KEY (`id_utilisateur`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `alertes`
--
ALTER TABLE `alertes`
  MODIFY `id_alerte` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `commandes`
--
ALTER TABLE `commandes`
  MODIFY `id_commande` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `historique`
--
ALTER TABLE `historique`
  MODIFY `id_historique` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `produits`
--
ALTER TABLE `produits`
  MODIFY `id_produit` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `stats_globales`
--
ALTER TABLE `stats_globales`
  MODIFY `id_stat` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  MODIFY `id_utilisateur` int(11) NOT NULL AUTO_INCREMENT;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `alertes`
--
ALTER TABLE `alertes`
  ADD CONSTRAINT `alertes_ibfk_1` FOREIGN KEY (`id_produit`) REFERENCES `produits` (`id_produit`);

--
-- Contraintes pour la table `commandes`
--
ALTER TABLE `commandes`
  ADD CONSTRAINT `commandes_ibfk_1` FOREIGN KEY (`id_produit`) REFERENCES `produits` (`id_produit`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
