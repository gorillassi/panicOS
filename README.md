# 🧨 panicOS

> _A cursed 32-bit x86 OS booting from raw iron. Terminal only. No userspace. Just you and the kernel._

---

## 💡 Описание

**panicOS** — минималистичная операционная система с нуля на ассемблере и C для архитектуры x86.  
Создана как эксперимент в построении ядра с текстовым выводом, поддержкой прокрутки и базовым ELF-загрузчиком.

---

## ⚙️ Возможности

- **Текстовый VGA-драйвер**
  - Печать текста напрямую в видеопамять.
  - Прокрутка экрана при переполнении.
  - Поддержка позиционирования курсора.

- **Собственный загрузчик (MBR + bootmain.c)**
  - Включает A20.
  - Переход в protected mode.
  - Загрузка ядра из ELF-образа с диска.
  - Передача управления в `kernel_main()`.

- **Ядро**
  - 32-битный режим.
  - Вызов `console_write`, `printk`, `panic`.
  - Мгновенная очистка экрана.
  - Аварийная остановка при `panic()`.

- **UART-вывод**
  - Логирование всего консольного вывода по COM-порту.
  - Совместимость с отладчиками.

---

## 🚀 Сборка и запуск

```sh
make panicOS.img      # сборка образа
make run              # запуск в QEMU
make run-nox          # запуск в headless-режиме
```

---

## 🧪 Тестирование

```sh
make test             # сравнение вывода с эталоном
```

---

## 🐛 Отладка (GDB)

```sh
make debug            # отладка ядра
make debug-boot       # отладка загрузчика (mbr)
```

---

## 📁 Структура

```
├── mbr.S             # 16-bit MBR загрузчик
├── bootmain.c        # C-код загрузки ядра (ELF)
├── kernel.c          # Точка входа ядра
├── console.c/.h      # VGA и UART вывод
├── drivers/          # VGA, UART
├── elf.h             # ELF32 формат
├── Makefile          # Сборка и запуск
└── README.md
```

---

## 🛠 Как использовать panicOS

### ✅ Требования

- `gcc`, `make`, `ld`, `nasm` — для сборки;
- `qemu-system-i386` — для эмуляции;
- опционально: `gdb` — для отладки.

Установить на Linux (Debian/Ubuntu):

```sh
sudo apt install build-essential qemu-system-x86 gdb
```

---

### ▶️ Запуск

```sh
make panicOS.img      # собрать образ
make run              # запустить в QEMU
```

Вы увидите фирменный загрузочный баннер:

```
>> panicOS bootloader initializing...
:: panicOS ::
system integrity: COMPROMISED
boot sequence: chaotic
welcome, rootless entity
```

---

### 💬 Работа с системой

- Система запускается и печатает приветствие.
- Вывод производится через VGA и UART одновременно.
- Набора команд нет — это ядро, не userspace.
- Для модификации поведения — редактируйте `kernel.c`, пересобирате.

