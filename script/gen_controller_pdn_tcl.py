

template = """
define_pdn_grid \\
    -macro \\
    -instances {} \\
    -name {} \\
    -starts_with POWER \\
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \\
    -grid {} \\
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \\
    -grid {} \\
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

add_pdn_stripe -grid {} -layer Metal4 -width 2.36 -offset 1.18 -spacing 0.28 -pitch 426.86 -starts_with GROUND -number_of_straps 2

"""

controller_macros = [ "i_chip_core.i_hachure_soc.i_frv_1",
                        "i_chip_core.i_hachure_soc.i_frv_2",
                        "i_chip_core.i_hachure_soc.i_frv_4",
                        "i_chip_core.i_hachure_soc.i_frv_8",
                        "i_chip_core.i_hachure_soc.i_frv_4ccx",
                        "i_chip_core.i_hachure_soc.i_frv_1bram",
                        "i_chip_core.i_hachure_soc.i_frv_8bram"]


for i, contr in enumerate(controller_macros):
    name = "controller_{}".format(i)
    print(template.format(contr, name, name, name, name))