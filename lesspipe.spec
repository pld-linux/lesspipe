%bcond_without  tests
#
Summary:	Input preprocessor for less
Summary(pl.UTF-8):	Preprocesor wejścia dla narzędzia less
Name:		lesspipe
Version:	2.07
Release:	1
License:	GPL v2
Group:		Applications/Text
Source0:	https://github.com/wofr06/lesspipe/archive/refs/tags/v%{version}.tar.gz
# Source0-md5:	37325c7c0f3e43791882774f5b60bb9a
URL:		https://www-zeuthen.desy.de/~friebel/unix/lesspipe.html
BuildRequires:	perl-base
BuildRequires:	rpmbuild(macros) >= 1.316
Suggests:	file
Suggests:	gnupg
Suggests:	highlight >= 3.0
Suggests:	mailcap >= 2.3
Suggests:	objdump
Suggests:	openssl-tools
Conflicts:	highlight < 2.16
Conflicts:	less < 394-7.1
Conflicts:	tar < 1:1.22
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
lesspipe is an input preprocessor for less.

Before less opens a file, it first gives your input preprocessor a
chance to modify the way the contents of the file are displayed.

This package contains PLD Linux script to display various archive
contents in human readable way.

%description -l pl.UTF-8
lesspipe to preprocesor wejścia dla narzędzia less.

Zanim less otworzy plik, najpierw pozwala preprocesorowi zmodyfikować
sposób wyświetlania pliku.

Ten pakiet zawiera skrypt z PLD Linuksa wyświetlający zawartość
różnych archiwów w sposób czytelny dla człowieka.

%prep
%setup -q

%{__sed} -E -i -e '1s,#!\s*/usr/bin/env\s+perl(\s|$),#!%{__perl}\1,' \
      archive_color \
      code2color \
      sxw2txt \
      vimcolor

%{__sed} -E -i -e '1s,#!\s*/usr/bin/env\s+bash(\s|$),#!/bin/bash\1,' \
      lesscomplete

%build
./configure \
    --prefix=%{_prefix} \
    --shell=/bin/bash

%{__make}

%{__sed} -E -i -e '1s,#!\s*/usr/bin/env\s+bash(\s|$),#!/bin/bash\1,' \
      lesspipe.sh

%if %{with tests}
%{__make} test
%endif

%install
rm -rf $RPM_BUILD_ROOT

install -d $RPM_BUILD_ROOT/etc/env.d

%{__make} install \
    DESTDIR=$RPM_BUILD_ROOT

# Prepare env file
cat > $RPM_BUILD_ROOT/etc/env.d/LESSOPEN <<'EOF'
LESSOPEN="|lesspipe.sh %s"
EOF

%clean
rm -rf $RPM_BUILD_ROOT

%post
%env_update

%postun
%env_update

%files
%defattr(644,root,root,755)
%attr(755,root,root) %{_bindir}/%{name}.sh
%attr(755,root,root) %{_bindir}/archive_color
%attr(755,root,root) %{_bindir}/code2color
%attr(755,root,root) %{_bindir}/lesscomplete
%attr(755,root,root) %{_bindir}/sxw2txt
%attr(755,root,root) %{_bindir}/vimcolor
#%{_datadir}/bash-completion/less_completion
%{_mandir}/man1/lesspipe.1*
%config(noreplace,missingok) %verify(not md5 mtime size) /etc/env.d/*
