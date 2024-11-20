MacOS version able to offer GUI of [flashrom.org](https://www.flashrom.org/) application.

Initial version worked with 1.2 flashrom so would not cover all chip memories, it worked under MacOS 10.14 and above MacOS.

An update to flashrom 1.4 was done by the creator on november 17th 2024 but worked only under MacOS 12.4 (see https://github.com/MacThings/g-flash/issues/1)

It is still not clear how the conversion from https://github.com/flashrom/flashrom is done by the creator inside the Xcode project.

Corrections in the Xcode project have been made so flashrom 1.4 can now work again with MacOS 10.14 (Xcode 11.3.1 has been used).

IMPORTANT: the G-flash application will work directly under Monterey (tested on two iMac) but under Mojave (tested on tow iMac and one MacBook Air), it requires to patch libusb and libftdi packages. The easiest way consists installing brew then install both libraries:

curl -fsSL -o install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

Sudo access requires to enter password as an administrator

brew install libusb

brew install libftdi
