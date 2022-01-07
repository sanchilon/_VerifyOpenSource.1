#! /usr/bin/env bash
set -xf
function rename_files {
    find=$1
    replace_with=$2
    wildcard=$3
    if [[ $wildcard ]]; then
        files_to_rename=$(find . -name "*$find*")
    else
        files_to_rename=$(find . -name "$find")
    fi
    if [[ $files_to_rename ]]; then
        IFS=$'\n'       # make newlines the only separator
        set -f          # disable globbing
        for file in $files_to_rename; do
            if [[ $wildcard ]]; then
                mv "$file" "${file/$find/$replace_with}"
            else
                mv "$file" "${file/\/$find//$replace_with}"
            fi
        done
        IFS=''
    fi
}

# ggrep is an alias on Mac for gnu grep - brew install grep
function replace_inside_files {
    find=$1
    replace_with=$2
    files=$(ggrep --exclude-dir=builds \
                  --exclude-dir=scripts/sources \
                  --exclude=transform.sh \
                  --exclude=prepare.pl \
                  --exclude=README.md \
                  --exclude=README-fr.md \
                  --exclude-dir=node_modules \
                  --exclude-dir=ios/Pods \
                  --exclude-dir=.git \
                  --recursive \
                  --files-with-matches "$find" .)
    if [[ $files ]]; then
        IFS=$'\n'       # make newlines the only separator
        set -f          # disable globbing
        for file in $files; do
            sed -i "" "s~${find}~${replace_with}~g" "$file"
        done
        IFS=''
    fi
}

function replace {
    find=$1
    replace_with=$2
    replace_inside_files "$find" "$replace_with"
    rename_files "$find" "$replace_with" "1"
}
BACKUP_FOLDER=".git-backup-$(date "+%Y%m%d%H%M%S")"
mv ./OntarioVerify/.git "../${BACKUP_FOLDER}"
##########################
set +f
rm -Rf ./OntarioVerify/.github
rm ./OntarioVerify/*.sh
rm ./OntarioVerify/Contributing.md
rm -Rf ./OntarioVerify/src/__mocks__/trust
cp ./scripts/sources/README.md ./OntarioVerify/
cp ./scripts/sources/README-fr.md ./OntarioVerify/
cp ./scripts/sources/tsconfig.json ./OntarioVerify/
cp ./scripts/sources/.env.template ./OntarioVerify/
cp ./scripts/sources/LICENSE.txt ./OntarioVerify/
cp ./scripts/sources/package.json ./OntarioVerify/
cp ./scripts/sources/src/__mocks/*.json ./OntarioVerify/src/__mocks__/
cp ./scripts/sources/src/assets/images/* ./OntarioVerify/src/assets/images/
cp ./scripts/sources/src/containers/home/*.tsx ./OntarioVerify/src/containers/home/
cp ./scripts/sources/android/app/*.json ./OntarioVerify/android/app/
cp -R ./scripts/sources/android/app/src/main/res/mipmap-hdpi/*.png ./OntarioVerify/android/app/src/main/res/mipmap-hdpi/
cp -R ./scripts/sources/android/app/src/main/res/mipmap-ldpi/*.png ./OntarioVerify/android/app/src/main/res/mipmap-ldpi/
cp -R ./scripts/sources/android/app/src/main/res/mipmap-mdpi/*.png ./OntarioVerify/android/app/src/main/res/mipmap-mdpi/
cp -R ./scripts/sources/android/app/src/main/res/mipmap-xhdpi/*.png ./OntarioVerify/android/app/src/main/res/mipmap-xhdpi/
cp -R ./scripts/sources/android/app/src/main/res/mipmap-xxhdpi/*.png ./OntarioVerify/android/app/src/main/res/mipmap-xxhdpi/
cp -R ./scripts/sources/android/app/src/main/res/mipmap-xxxhdpi/*.png ./OntarioVerify/android/app/src/main/res/mipmap-xxxhdpi/
cp -R ./scripts/sources/ios/OpenVerify/Images.xcassets ./OntarioVerify/ios/OpenVerify/
cp ./scripts/sources/ios/*.plist ./OntarioVerify/ios/
sed -i "" "s~Open Verify~VérifOuverte~g" ./OntarioVerify/src/translations/fr.json

STAR_COMMENT_LICENSE=$(cat <<EOF
/*
   Copyright 2021 Queen’s Printer for Ontario

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
EOF
)
set -f

cp -R "../${BACKUP_FOLDER}" ./OntarioVerify/.git

##################

replace "Verify Ontario" "Open Verify"
replace "VerifyOntario" "OpenVerify"
replace "OntarioVerify" "OpenVerify"
replace "ca.ontario.verify" "openverify.replace.me"
replace "VérifOntario" "VérifOuverte"
replace "OntarioLogo" "OpenVerifyLogo"
replace "OntarioQR" "OpenVerifyQR"
replace "OntarioCheckBox" "OpenVerifyCheckBox"
replace 'accessibilityLabel="Ontario"' 'accessibilityLabel="Open Verify"'
replace '"OpenVerifyLogoAlt": "Open Verify"' '"OpenVerifyLogoAlt": "Open Verify"'
replace "ontario-icon-alert-warning" "openverify-icon-alert-warning"
replace "ontario-icon-close" "openverify-icon-close"
replace "ontario_back_blue" "openverify_back_blue"
replace "ontario_base_logo" "openverify_base_logo"
replace "ontario_camera_logo" "openverify_camera_logo"
replace "ontario-icon-alert-error" "openverify-icon-alert-error"
replace "ontario_base_logo_dark" "openverify_base_logo_dark"
sed -i "" "s~# Firebase~~g" ".gitignore"
sed -i "" "s~/ios/GoogleService-Info.plist~~g" ".gitignore"
sed -i "" "s~/android/app/google-services.json~~g" ".gitignore"
rename_files "ca" "openverify" ""
rename_files "ontario" "replace" ""
rename_files "verify" "me" ""

##################


##################
files=$(ggrep '--exclude-dir=android/builds' \
                '--exclude-dir=scripts/sources' \
                '--exclude=transform.sh' \
                ' --exclude=prepare.pl' \
                '--exclude-dir=node_modules' \
                '--exclude-dir=ios/Pods' \
                '--exclude-dir=.git' \
                '--exclude-dir=test-data' \
                '--recursive' \
                '--files-without-match' \
                "Copyright " . \
                | ggrep -E '(\.ts|\.tsx|\.js|\.jsx|\.h|\.m|\.strings|\.java)$')
if [[ $files ]]; then
    IFS=$'\n'       # make newlines the only separator
    set -f          # disable globbing
    for file in $files; do
        echo -e "$STAR_COMMENT_LICENSE\n$(cat "$file")" > "$file"
    done
fi



#yarn
#yarn prettier -w --bracket-same-line 'src' '!src/__mocks__'
#yarn eslint src
#yarn tsc
#yarn jest
#cd ios && npx pod-install
