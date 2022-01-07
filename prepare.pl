#!/usr/bin/perl -w

use strict;
use warnings;
use File::Path qw( rmtree );
#use File::Copy::Recursive qw(dircopy);
#use Git::Repository;

BEGIN {
  print("\n\n#####################################\n");
    print("Begin Open Sourcing \n");
   print("#####################################\n");
}
my $projRoot = "./OntarioVerify";

sub initialize;
sub transform;
sub cleanup;
sub diffbrnch;
sub pushbranch;
sub zipit;


initialize();
transform();
#cleanup();
#diffbrnch();
#pushbranch();
#zipit();


#################################################################
sub initialize{
my ($version) = @_;
  qx(rm -rf OntarioVerify);
  qx(git rm --cached -rf OntarioVerify);
  qx(rm -rf .git/modules && rm -f ./gitmodules);
  qx(git submodule add https://github.com/ongov/OntarioVerify);
  chdir("OntarioVerify");
  print qx(pwd); 
  qx(git switch -C main origin/main);
  qx(git pull --rebase origin main);
  qx(cp -R ../openverify .);
#qx(git switch -C open-source-preview-1.2.1);
#qx(echo "openverify/" >> .gitignore);
#qx(git commit -am "add .gitignore ");
#qx(git switch -C open-source-script-1.2.1 origin/open-source-script-1.2.1);
#qx(git switch open-source-preview-1.2.1);
#qx(git restore --source open-source-script-1.2.1 openverify);
#qx(git clean -xdf);

}

sub transform{
#chdir("../");
print(qx(pwd),"\n");
print(" Transforming .... \n\n");
qx(./openverify/transform.sh);
qx(./openverify/transform.sh);
qx(./openverify/transform.sh);
print(" Removing openverify folder  ....",qx(pwd)," \n\n");
rmtree("openverify");

#qx(rm -rf openverify);

}

sub cleanup {
  print("Cleaning up folder \n\n");
  qx(rm -rf "./openverify/");
  chdir($projRoot);
  qx(watchman watch-del-all);
  qx(yarn cache clean --force);
  qx(cd ios && xcodebuild clean && pod cache clean --all && rm -rf build && rm -rf Pods/);
  qx(cd android && ./gradlew clean && rm -rf .gradle && rm -rf  build);
  print(qx(pwd));
  qx(rm -rf /tmp/metro-*);
  qx(rm -rf  /src/assets/images/.png-cache);
  qx(rm -f .env);
  qx(rm -rf node_modules/);
  
}

sub diffbrnch{
  qx(git remote add -f opnsrc https://github.com/ongov/OpenVerify.git);
  qx(git remote update);
  qx(git diff open-source-preview-1.2.1..remotes/opnsrc/main > diff_openverify_details.txt);
  qx(git diff --name-status open-source-preview-1.2.1..remotes/opnsrc/main  > diff_openverify.txt);
  qx(git diff  open-source-preview-1.2.1..remotes/opnsrc/main  > diff_ontario_prod.txt);
  qx(git diff --name-status open-source-preview-1.2.1..remotes/opnsrc/main  >  diff_ontario_prod_details.txt);
  qx(git switch main);
  qx(git fetch --tags --all);
 qx(git fetch origin +refs/tags/1.1.1:refs/tags/1.1.1);
qx(git checkout tags/1.1.1 -b 1.1.1);
qx(git switch main);
qx(git diff main..1.1.1 > diff_ontario_prod.txt);
qx(git diff  --name-status main..1.1.1 > diff_ontario_prod_details.txt);
}
sub pushbranch{
  qx(git push -u origin open-source-preview-1.2.1);
}
sub zipit{
qx(git switch open-source-preview-1.2.1);
qx(git fetch --all);
qx(git archive OpenVerify.zip origin/open-source-preview-1.2.1);
}

END {
print("\n\n#####################################\n");
 print("End Open Sourcing \n");
 print("#####################################\n");
}