<div align="center">
    <a href="https://github.com/RaidenSora/currency/">
        <img src="https://github.com/user-attachments/assets/33b7307e-e1b6-44d9-92f1-2c6067cf1015" height="100">
    </a>
    <h1>CCERM</h1>
</div>

<div align="center">

<a href="https://github.com/RaidenSora"><img src="https://img.shields.io/badge/mentained%20by-raidensora-blue.svg" alt="RaidenSora" /></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</div>

<div align="center">

Currency Converter and Exchange Rate Monitor.
<br>
CCERM android app converts currency and displays the current exchange rate of different currencies worldwide. Data and API used for this app can be found at [API Ninja](https://nodejs.org/en/download/) and [Currency API](https://app.currencyapi.com/) website. 
</div>



## Setup

> NOTE: Make sure you have Flutter SDK installed in your system before proceeding to setup, if not you can follow the installation docs [here](https://docs.flutter.dev/get-started/install).
Run the following commands from your terminal:

```sh
$ git clone https://github.com/RaidenSora/currency
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
dart run build_runner build
```

Now you can run this flutter project 🚀

```sh
$ flutter run
```
