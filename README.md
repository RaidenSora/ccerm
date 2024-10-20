<div align="center">
    <a href="https://github.com/RaidenSora/ccerm/">
        <img src="https://github.com/user-attachments/assets/33b7307e-e1b6-44d9-92f1-2c6067cf1015" height="100">
    </a>
    <h1>CCERM</h1>
</div>

<div align="center">

<a href="https://github.com/RaidenSora"><img src="https://img.shields.io/badge/progress-95%25-green.svg" alt="RaidenSora" /></a>
<a href="https://github.com/RaidenSora/ccerm/commits/main/"><img src="https://img.shields.io/github/commit-activity/t/RaidenSora/ccerm" alt="Commits"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</div>

<div align="center">

Currency Converter and Exchange Rate Monitor.
</div>

## ✍️ About

Welcome to CCERM( Currency Converter and Exchange Rates Monitor) application! We are dedicated to providing users with accurate, real-time currency conversion and exchange rate information. Our goal is to empower travelers, businesses, OFWs, and anyone dealing with international transactions by simplifying the process of currency exchange. With a user-friendly interface and reliable data sourced from trusted financial institutions, we aim to help you make informed decisions and stay updated in a fast-paced global economy. Thank you for choosing us as your go-to resource for currency exchange needs.

## 📦 Releases 

First release is [here](https://github.com/RaidenSora/ccerm/releases/tag/release-v1) 👀
See latest releases [HERE](https://github.com/RaidenSora/ccerm/releases)

## 📎 CIY (Compile-It-Yourself)

> NOTE: Make sure you have Flutter SDK installed in your system before proceeding to setup, if not you can follow the installation docs [here](https://docs.flutter.dev/get-started/install).

Run the following commands from your terminal:

```sh
$ git clone https://github.com/RaidenSora/ccerm
$ flutter pub get
```
Create a free account on [Currency API](https://currencyapi.com/) and get your api key in dashboard.
<br>
Add a `.env` file at the root of the project with this format.

```.env
API-KEY=CURRENCYAPI_API_KEY
```
> IMPORTANT! Add both `.env` and `env.g.dart` files to your `.gitignore` file, otherwise, you might expose your environment variables.

Then run the generator:

```sh
$ dart run build_runner build
```

Now you can run this flutter project 🚀

```sh
$ flutter run
```
