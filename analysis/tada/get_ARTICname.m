function ARTICname = get_ARTICname (i_ARTIC)
load t_params

switch i_ARTIC
    case i_LX 
        ARTICname = 'LX';
    case i_JA 
        ARTICname = 'JA';
    case i_UY
        ARTICname = 'UH';
    case i_LY 
        ARTICname = 'LH';
    case i_CL 
        ARTICname = 'CL';
    case i_CA 
        ARTICname = 'CA';
    case i_TL
        ARTICname = 'TL';
    case i_TA
        ARTICname = 'TA';
    case i_NA
        ARTICname = 'NA';
    case i_GW
        ARTICname = 'GW';
    case i_F0a
        ARTICname = 'F0a';
    case i_PIa
        ARTICname = 'PIa';
    case i_SPIa
        ARTICname = 'SPIa';
    case i_HX
        ARTICname = 'HX';
end