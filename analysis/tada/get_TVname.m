function TVname = get_TVname (i_TV)
load t_params
switch i_TV
    case i_LA 
        TVname = 'LA';
    case i_PRO 
        TVname = 'LP';
    case i_TBCD 
        TVname = 'TBCD';
    case i_TBCL 
        TVname = 'TBCL';
    case i_TTCD 
        TVname = 'TTCD';
    case i_TTCL 
        TVname = 'TTCL';
    case i_TTCR 
        TVname = 'TTCR';
    case i_JAW 
        TVname = 'JAW';
    case i_VEL 
        TVname = 'VEL';
    case i_GLO 
        TVname = 'GLO';
    case i_F0 
        TVname = 'F0';
    case i_PI
        TVname = 'PI';
    case i_SPI 
        TVname = 'SPI';
    case i_TR 
        TVname = 'TR';
end
