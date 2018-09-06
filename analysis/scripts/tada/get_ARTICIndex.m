function i_ARTIC = get_ARTICIndex (ARTICname)
load t_params
switch ARTICname
    case 'LX' 
        i_ARTIC = i_LX;
    case 'JA' 
        i_ARTIC = i_JA;
    case 'UH'
        i_ARTIC = i_UY;
    case 'LH' 
        i_ARTIC = i_LY;
    case 'CL' 
        i_ARTIC = i_CL;
    case 'CA' 
        i_ARTIC = i_CA;
    case 'TL'
        i_ARTIC = i_TL;
    case 'TA'
        i_ARTIC = i_TA;
    case 'NA'
        i_ARTIC = i_NA;
    case 'GW'
        i_ARTIC = i_GW;
    case 'F0a'
        i_ARTIC = i_F0a;
    case 'PIa'
        i_ARTIC = i_PIa;
    case 'SPIa'
        i_ARTIC = i_SPIa;
    case 'HX'
        i_ARTIC = i_HX;
end