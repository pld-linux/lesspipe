# TODO
# - consider this version (with code2color etc.):
#	http://www-zeuthen.desy.de/~friebel/unix/lesspipe.html
#
Summary:	Input preprocessor for less
Summary(pl.UTF-8):	Preprocesor wejścia dla narzędzia less
Name:		lesspipe
Version:	1.54
Release:	1
License:	GPL v2
Group:		Applications/Text
Source0:	%{name}.sh
BuildRequires:	rpmbuild(macros) >= 1.316
Suggests:	file
Suggests:	highlight
Suggests:	mailcap >= 2.3
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

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{_bindir},/etc/env.d}
install -p %{SOURCE0} $RPM_BUILD_ROOT%{_bindir}

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
%config(noreplace,missingok) %verify(not md5 mtime size) /etc/env.d/*
