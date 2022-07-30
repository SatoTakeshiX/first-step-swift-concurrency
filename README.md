# 「Swift Concurrency入門」サンプルコード

本リポジトリは書籍「Swift Concurrency入門」のサンプルコードを提供するリポジトリです。

「Swift Concurrency入門」はSwift 5.5から登場したSwift Concurrencyを解説する技術本です。
Swift Concurrencyの概念はもちろん、`async/await`、`Actor`、`@MainActor`、`Task`、`AsyncSequence`、`Sendable`といったSwift Concurrencyを利用する上で欠かせない型の使い方や、以前のコードとSwift Concurrencyのコードがどのように異なるのかの比較も紹介しています。

「Swift Concurrency入門」は同人版と商業版があります。
どちらもサンプルコードは本リポジトリで管理します。

サンプルコードの改定や本文の改定・誤字修正も本リポジトリでお知らせします。

# Book URL

* 商業版「一冊でマスター！Swift Concurrency入門」
    * https://nextpublishing.jp/book/15157.html
* 同人版「Swift Concurrency入門」
    * https://personal-factory.booth.pm/items/3888109

# 目次

## 【第一章 async/await】

非同期処理を`async/await`で記述できるようになりました。従来クロージャーによるコールバックと比べてどのように簡潔、安全になったのかを解説します。

[サンプルコード1](https://github.com/SatoTakeshiX/first-step-swift-concurrency/tree/main/try-concurrency.playground)

[サンプルコード2](https://github.com/SatoTakeshiX/first-step-swift-concurrency/tree/main/parallel-execution)


## 【第二章 Actor/データ競合を守る新しい型】

マルチスレッドプログラミングにおいて、データ競合（data race）は典型的な不具合のひとつです。Swift Concurrencyではデータ競合を防ぐ新しい型、`Actor`が導入されました。どのような特徴があるのかを解説します。

[サンプルコード](https://github.com/SatoTakeshiX/first-step-swift-concurrency/tree/main/try-concurrency.playground)

## 【第三章 AsyncSequence】

繰り返し処理でお馴染みの`for`文を非同期で書きましょう。

`for await in`ループとそれを実現する`AsyncSequence`プロトコルを学びます。

[サンプルコード](https://github.com/SatoTakeshiX/first-step-swift-concurrency/tree/main/AsyncSequence)


## 【第四章 Task】

Swift Concurrencyの並行処理は`Task`という単位で行われます。`Task`の特徴を解説します。

[サンプルコード](https://github.com/SatoTakeshiX/first-step-swift-concurrency/tree/main/structured-concurrency)


## 【第五章 Sendable】
`Actor`を始め、並行コードにおいて、データ競合なしにデータを同時並行処理間で渡せるかどうかを表す新しいプロトコル`Sendable`が登場しました。`Sendable`を解説し、コンパイラがエラーを出力した場合の対処方法を探ります。

[サンプルコード](https://github.com/SatoTakeshiX/first-step-swift-concurrency/tree/main/SendableSample)


## 【第六章 既存のプロジェクトにSwift Concurrencyを導入】

既存のプロジェクトにSwift Concurrencyを導入する方法を解説します。`async/await`、`@MainActor`だけでなく、Swift 5.6の対応も行います。

[サンプルコード](https://github.com/SatoTakeshiX/first-step-swift-concurrency/tree/main/ConcurrencyForExistingApp)

# ライセンス

本サンプルコードはMITで配布しています。
詳細は[こちら](https://github.com/SatoTakeshiX/first-step-swift-concurrency/blob/main/LICENSE)をご覧ください。 

# Pull Requestやissueについて

サンプルコード自体の疑問や改善点があれば、ぜひPull Requestやissueの作成をお願いします。
ただし、書籍上、解説のためにわざとワーニングを出している箇所があるので予めご了承ください。

書籍本文自体の疑問があれば下記メールアドレスにまでご連絡ください。

* t.sato@personal-factory.com

# サンプルコード履歴

releaseページをご覧ください。

https://github.com/SatoTakeshiX/first-step-swift-concurrency/releases