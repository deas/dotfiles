# https://www.nushell.sh/book/configuration.html#configuring-nu-as-a-login-shell

if ("/nix/var/nix/profiles/default" | path exists ) {
    $env.NIX_PROFILES = "/nix/var/nix/profiles/default /home/deas/.nix-profile"
    $env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.nix-profile/bin" ) | prepend "/nix/var/nix/profiles/default/bin/nix")
}
