# _mhddos_proxy_win_installer_
Скрипт для зручної роботи з `mhddos_proxy` на Windows 7-11
## Запуск
1. Завантажити [`mhddos.bat`](https://github.com/wvzxn/mhddos_proxy_win_installer/releases/download/release/mhddos.bat) в зручне для вас місце
2. Запустити `mhddos.bat` від імені адміністратора
___
![image](https://user-images.githubusercontent.com/87862400/175060595-4484fc98-1237-42f7-bddc-f817c3410995.png)
___
## Опис
`mhddos_proxy` потребує `Git` та `python` (який, в свою чергу, потребує `Visual C++ Redist Pack`).

Основна функція скрипту - зробити все за вас, тобто автоматично встановити те, чого не вистачає. Також, ви можете:
- змінити команду для mhddos_proxy
- запланувати запуск скрипту разом з системою

#### Windows 7
Для роботи на Windows 7 потрібно мати:
- Останні оновлення Windows (_автоматичний інсталятор_ [`UpdatePack7R2`](https://blog.simplix.info/updatepack7r2))
- [`.NET Framework`](https://www.microsoft.com/en-us/download/details.aspx?id=42642) 4.5.2 або вище
- [`Powershell`](https://www.microsoft.com/en-us/download/details.aspx?id=34595) 3.0 або вище

#### Джерела
- [`mhddos_proxy`](https://github.com/porthole-ascend-cinnamon/mhddos_proxy)
- [`vcr`](https://repack.me/software/systemreq/31-microsoft-visual-c-2005-2008-2010-2012-2013-2019-2022-redistributable-package.html)
- [`python portable (nuget)`](https://www.nuget.org/api/v2/package/python/3.8.10)
- [`git portable`](https://github.com/git-for-windows/git/)

___
