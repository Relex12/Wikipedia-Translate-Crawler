# Wikipedia Translate Crawler

A Wikipedia crawler that gives the worst translated page around an English starting page using hypertext links

![](https://img.shields.io/github/license/Relex12/Wikipedia-Translate-Crawler) ![](https://img.shields.io/github/repo-size/Relex12/Wikipedia-Translate-Crawler) ![](https://img.shields.io/github/languages/top/Relex12/Wikipedia-Translate-Crawler) ![](https://img.shields.io/github/last-commit/Relex12/Wikipedia-Translate-Crawler) ![](https://img.shields.io/github/stars/Relex12/Wikipedia-Translate-Crawler)

Check out on GitHub

[![Wikipedia-Translate-Crawler](https://github-readme-stats.vercel.app/api/pin/?username=Relex12&repo=Wikipedia-Translate-Crawler)](https://github.com/Relex12/Wikipedia-Translate-Crawler)

[Lire en Français](https://relex12.github.io/fr/Wikipedia-Translate-Crawler)

---

## Summary

[toc]

## What it is

This crawler will search for all pages related to a topic on Wikipedia in a certain language called source language, let's say English, and for each related page it will check how good is the translated page in another language called target language, let's say French.

For example, if you know a lot about Computer Science and you want to improve Wikipedia pages related to CS in French, you can use the script to which pages related to the topic have bad translation and can be considered a priority.

Basically, this script is meant to be used when you want to contribute to Wikipedia by translating pages.

## How to run

Considering the example above, you can run the following:

```
git clone https://github.com/Relex12/Wikipedia-Translate-Crawler.git
cd Wikipedia-Translate-Crawler
./crawler.sh Computer_Science fr
```

## Script behavior

At first, the script is checking for Internet connection, the options and the existence of both source and translated pages (i.e the page you give as an argument and it's translated version) and then create a workspace with the name of the source page.

* Step one is downloading all pages that might be necessary, two subdirectories will be created for both the source and target languages, and will be removed at the end of the script
* Step two is processing pages, that means each page is cropped to get only its content.
* Step three is gathering data, which consist of computing and comparing a score for each couple of source and translated pages.

The output is written in a sorted CSV file, where the first column is the score of page's translation, then the name of the source page, the URL of the translated page, and additional information about quality tags of the translated page.

This CSV file is also written to stdout with fancy colors depending on the score ratio and quality tags of the translated page.

The score is calculated according to this pseudo-code:

```
score = 0
for i in [<a>, <img>, <h2>, <h3>]
	score = score + N_src(i)/( N_trg(i)+1 )
```

where `N_src` and `N_trg` are respectively the number of the current tag in the source page and the target page.

## CLI arguments

```
Usage: ./crawler PAGE [TARGET_LANGUAGE=fr] [DEPTH=2] [SOURCE_LANGUAGE=en]
```

## Known issues and risky behaviors

* the script has not been tested with other languages that English as source and French as target, as most of the features depends on hard coded strings that are sought using `grep`, they might change a lot between different languages
* the depth option might not be taken into account by `wget` when crawling
* when there is, pages corresponding to ISBN number are included even if they are not relevant
* name pages with `:` will cause a `No such file or directory` error for `cat` and `grep` in step 2, and won't be considered as translation pages
* name pages with `,` might break the CSV formatting when writting to stdout, but it won't affect the score
* other issues and bizarre behaviors are probably still to be discovered


## License

The project is a small one. The code is given to the GitHub Community  for free, only under the MIT License, that is not too restrictive.
