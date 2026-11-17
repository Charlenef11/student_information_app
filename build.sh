# Mag-download ng Flutter SDK (Stable channel)
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Idagdag ang flutter sa PATH ng build environment
export PATH="$PATH:`pwd`/flutter/bin"

# I-verify ang flutter version
flutter --version

# I-enable ang web support at i-build ang app
flutter config --enable-web
flutter build web --release