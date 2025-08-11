
local WeaponAssets = game:GetService("ReplicatedStorage").Assets.WeaponsAsset

local WeaponClass =   require(game:GetService("ReplicatedStorage").Shared.Weapons.WeaponClass )  

local DescCreate = require(game:GetService("ReplicatedStorage").Shared.Utility.DescriptionCreator )

local Dagger = WeaponClass.new({

     WeaponName = "Dagger";

     Type  = "Light"; -- Type (Heavy, Light, Medium)
     BlockableDamageTypes = {"Blade","None"}; -- Can Block Blade? Can't?...
     DamageType = "Blade"; -- It's a blade? None? 
     Animtracks = game.ReplicatedStorage.Animations.WeaponsAnimations.Dagger; -- AnimTracks
    
    StatusBlacklisted = {
        ["M1"] = {"Stunned", "EndLag", "InM1" },
        ["Block"] = {"EndLag"},
        ["AirAttack"] = {"EndLag", "Stunned"},
        ["Heavy"] = {"Stunned", "EndLag"},
        ["DownSlam"] = {"Stunned", "EndLag"},
        ["Feint"] = {"Stunned", "EndLag" } ,
        ["Sprint Strike"] = {"Stunned", "EndLag"} ,
    },

    -- Status that some weapon attacks can bypass.
    CanByPass = {
        ["Heavy"] = {"Block"}
    },


    -- Track Speed
     AnimTracksSpeed = {
         ["M1"] = {
            [1] = 1.2,
            [2] = 1.6,
            [3] = 1.8,
            [4] = 2,
        },

        ["AirAttack"] = 1,
        ["Heavy"] = 1,
        ["DownSlam"] = 1,
        ["Feint"] = 1,
        ["Sprint Strike"] = 0.8,
        ["Block"] = 1,
        ["Parry"] = 1,

     },

     -- Default CD.
     DefaultCooldown = {
        ["AirAttack"] = 1,
        ["Heavy"] = 2,
        ["DownSlam"] = 5,
        ["Feint"] = 1,
        ["Sprint Strike"] = 2,
     },

     -- Damages Per Hit
     Damages = {
        ["M1"] = {
            [1] = 5,
            [2] = 5,
            [3] = 5,
            [4] = 6,
        },

        ["AirAttack"] = 1,

        ["DownSlam"] = 3,

        ["Heavy"] = {
            [1] = 15.6
        },

        ["Sprint Strike"] = 5,
     },
   
     ServerHitboxTiming = {
        ["M1"] = {
            [1] = .3,
            [2] = .2,
            [3] = .2,
            [4] = .3
        },
        ["AirAttack"] = .3,


        ["DownSlam"] = 1,
        ["Heavy"] = .7,
        ["Sprint Strike"]  = .3
     },

    AttackStunTime = {
         ["M1"] = {
            [1] = .8,
            [2] =  .8,
            [3] =  .8,
            [4] = .8
        },
          ["AirAttack"] = {
            [1] = .3
        },

        ["DownSlam"] = 1,
        ["Heavy"] = 1,
        ["Sprint Strike"] = .8 
    },


     HitboxSize = {
         ["M1"] = {
            [1] = 4,
            [2] = 4,
            [3] = 4,
            [4] = 4
        },
        ["AirAttack"] = 3,

        ["Sprint Strike"] = 4,

        ["DownSlam"] = 1,
        ["Heavy"] = 3 
     },
     HitboxPosition = {

        ["Sprint Strike"] =  CFrame.new(0,0,-2),

        ["M1"] = {
            [1] = CFrame.new(0,0,-2),
            [2] = CFrame.new(0,0,-2),
            [3] = CFrame.new(0,0,-2),
            [4] = CFrame.new(0,0,-2)
        },
          ["AirAttack"] = {
            [1] = CFrame.new(0,0,-2)
        },

        ["DownSlam"] = CFrame.new(0,0,-2),
        ["Heavy"] = CFrame.new(0,0,-2)
     },

   
     EndLags = {
         ["M1"] = {
            [1] = .25,
            [2] = .18,
            [3] = .23,
            [4] = 1.3
        },

        ["Block"] = .1,
        ["Parry"] = .2,

        ["AirAttack"] = .5,
        ["DownSlam"] = 1,
        ["Sprint Strike"] = .01,
        ["Feint"] = .5,
        ["Heavy"] = 1

     }; -- M1 EndLag and other's skillset.
        
     WeaponModel = WeaponAssets.Dagger.Model.MainHandle; -- Just the Model that we will use for it.

     Desc =  DescCreate:Create("Dagger",
        "Small but very effective weapon. "
     ) ,

     HandType = "Dagger",

})

Dagger.CustomMoves = {}



return Dagger