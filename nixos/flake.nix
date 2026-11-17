{
  description = "NixOS + home-manager configuration for t (i3/X11, NVIDIA)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Helium is not in nixpkgs; this flake packages the upstream .deb.
    # Update it with: nix flake update helium
    helium = {
      url = "github:tomsch/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SF Mono patched with Nerd Fonts + Fira Code ligatures (Liga SFMono).
    # The font is not in nixpkgs, and Apple's license keeps it out.
    sf-mono-liga = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.t = import ./home.nix;
          }
        ];
      };
    };
}
