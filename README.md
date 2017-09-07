CFSSL pour GFI Orléans
======================

Permet de générer des certificats à partir d'un chaine à 3 niveaux (Root CA, Intermediate CA, End-User Certificate).

Il est nécessaire de déclarer les 2 certificats CA (Root CA, Intermediate CA) dans l'OS de l'utilisateur pour que les 
certificats End-User soient reconnus par le navigateur.

Installation
------------
```
docker-compose up
```

Générer un certificat wilcard à partir d'un nom de domaine
----------------------------------------------------------
- En ligne de commande sur le serveur

```
docker-compose exec intermediate sh
H=eqo.app # Nom de domaine supporté par le certificat
cfssl gencert -ca ca.pem -ca-key ca-key.pem -hostname "*$H,*.$H" ca_intermediate_config.json | cfssljson -bare "$H"
exit
```

- Via l'API REST

***TODO!***

Importer les certificats CA sous windows
----------------------------------------

- Convertir un certificat PEM en CRT (pour import windows)

```bash
openssl x509 -outform der -in root/ca.pem -out root/ca.crt
openssl x509 -outform der -in intermediate/ca.pem -out intermediate/ca.crt
```

- Lancer "certmgr.msc"

- Selectionner "Authorité de confiance > Certificats"

- Dans le menu, choisir "Action > Toutes les tâches > Importer..."

- Choisir le fichier `root/ca.crt`
