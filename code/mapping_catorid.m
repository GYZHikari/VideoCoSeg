function id = mapping_catorid(name)
if ischar(name)
    switch lower(name)
        case 'aeroplane'
            id = 1;
        case 'bike'
            id = 2;
        case 'bird'
            id = 3;
        case 'boat'
            id = 4;
        case 'bottle'
            id = 5;
        case 'bus'
            id = 6;
        case'car'
            id = 7;
        case'cat'
            id = 8;
        case 'chair'
            id = 9;
        case'cow'
            id = 10;
        case 'table'
            id = 11;
        case'dog'
            id = 12;
        case'horse'
            id = 13;
        case'motorbike'
            id = 14;
        case 'person'
            id = 15;
        case 'plant'
            id = 16;
        case 'sheep'
            id = 17;
        case 'sofa'
            id = 18;
        case 'train'
            id = 19;
        case 'tv'
            id = 20;
            
    end
else
    switch lower(name)
        case 1
            id = 'aeroplane';
        case 2
            id = 'bike';
        case 3
            id = 'bird';
        case 4
            id = 'boat';
        case 5
            id = 'bottle';
        case 6
            id = 'bus';
        case 7
            id = 'car';
        case 8
            id = 'cat';
        case 9
            id = 'chair';
        case 10
            id = 'cow';
        case 11
            id = 'table';
        case 12
            id = 'dog';
        case 13
            id = 'horse';
        case 14
            id = 'motorbike';
        case 15
            id = 'person';
        case 16
            id = 'plant';
        case 17
            id = 'sheep';
        case 18
            id = 'sofa';
        case 19
            id = 'train';
        case 20
            id = 'tv';
    end
end