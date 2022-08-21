# Wikipédia Translate Crawler

Un crawler Wikipédia qui donne la pire traduction d'une page autour d'une page de départ en utilisant les liens hypertextes

![](https://img.shields.io/github/license/Relex12/Wikipedia-Translate-Crawler) ![](https://img.shields.io/github/repo-size/Relex12/Wikipedia-Translate-Crawler) ![](https://img.shields.io/github/languages/top/Relex12/Wikipedia-Translate-Crawler) ![](https://img.shields.io/github/last-commit/Relex12/Wikipedia-Translate-Crawler) ![](https://img.shields.io/github/stars/Relex12/Wikipedia-Translate-Crawler)

Regarder sur GitHub:

[![Wikipedia-Translate-Crawler](https://github-readme-stats.vercel.app/api/pin/?username=Relex12&repo=Wikipedia-Translate-Crawler)](https://github.com/Relex12/Wikipedia-Translate-Crawler)

[Read in English](https://relex12.github.io/Wikipedia-Translate-Crawler)

---

## Sommaire

* [Wikipédia Translate Crawler](#wikipédia-translate-crawler)
    * [Sommaire](#sommaire)
    * [Qu'est-ce que c'est ?](#qu'est-ce-que-c'est-)
    * [Comment l'exécuter](#comment-l'exécuter)
    * [Comportement du script](#comportement-du-script)
    * [Arguments de la ligne de commande](#arguments-de-la-ligne-de-commande)
    * [Problèmes connus et comportements hasardeux](#problèmes-connus-et-comportements-hasardeux)
    * [Licence](#licence)

<!-- table of contents created by Adrian Bonnet, see https://Relex12.github.io/Markdown-Table-of-Contents for more -->

## Qu'est-ce que c'est ?

Ce crawler va recherches les pages associées à un sujet sur Wikipédia dans une certaine langue appelée langue source, disons l'anglais, et pour page associée il va chercher la qualité de la page traduite dans une autre langue dite langue cible, disons le français.

Par exemple, si vous êtes bon en informatique et que vous voulez améliorer les pages Wikipédia en français associées à l'informatique, vous pouvez utiliser ce script pour savoir quelles pages associées à ce sujet ont une mauvaise traduction et qui peuvent être considérées prioritaires.

En somme, ce script est fait pour aider à contribuer à Wikipédia en traduisant des pages.

## Comment l'exécuter

En considérant l'exemple ci-dessus, vous pouvez faire comme ceci :

```
git clone https://github.com/Relex12/Wikipedia-Translate-Crawler.git
cd Wikipedia-Translate-Crawler
./crawler.sh Computer_Science fr
```

## Comportement du script

Au démarrage, le script vérifie la connexion à Internet, les options et l'existence à la fois de la page source et de la page traduite (c'est-à-dire la page que vous donnez en argument et sa version traduite) puis crée un workspace avec le nom de la page source.

* L'étape un est de télécharger toutes les pages qui peuvent être nécessaires, deux sous répertoires sont créés pour les langues source et cible et seront supprimés à la fin du script.
* L'étape deux est traiter les pages, ce qui veut dire que chaque page est réduite à son contenu uniquement.
* L'étape trois est de récupérer les données, ce qui consiste à calculer et comparer le score de chaque couple de page source et traduite.

La sortie du programme est écrite dans un fichier CSV trié, dans lequel la première colonne est le score de la traduction de la page, puis le nom de la page source, l'URL de la page traduite, et des informations additionnelles sur des labels de qualité de la page traduite.

Ce fichier CSV est aussi affiché dans la sortie standard stdout avec des couleurs selon le score et les labels de qualité de la page traduite.

Le score est calculé selon le pseudo-code suivant :

```
score = 0
for i in [<a>, <img>, <h2>, <h3>]
	score = score + N_src(i)/( N_trg(i)+1 )
```

où `N_src` et `N_trg` sont respectivement le nombre d'occurrences du tag HTML en cours dans la page source et la page traduite.

## Arguments de la ligne de commande

```
Usage: ./crawler PAGE [TARGET_LANGUAGE=fr] [DEPTH=2] [SOURCE_LANGUAGE=en]
```

## Problèmes connus et comportements hasardeux

* le script n'a pas été testé avec d'autres langues que l'anglais comme source et le français comme cible, comme la plupart des fonctionnalités dépendent de chaînes de caractères écrites en dur qui sont recherchées avec `grep`, elles risquent de différer beaucoup entre différentes langues
* l'option de profondeur Depth peut ne pas être prise en compte par `wget` lors du crawling
* lorsqu'il y en a, les pages correspondant à un numéro d'ISBN sont traitées bien qu'elles ne soient pas pertinantes
* les noms de page avec un `:` vont provoquer une erreur `No such file or directory` pour `cat` et `grep` dans l'étape 2, et ne seront pas considérées comme des pages de traduction
* les noms de page avec une `,` peuvent casser le formatage du fichier CSV, mais ça ne changera pas le score
* d'autres problèmes et comportements bizarres restent probablement à découvrir


## Licence

Ce projet est un petit projet. Le code source est donné librement à la communauté GitHub, sous la seule licence MIT, qui n'est pas trop restrictive.
