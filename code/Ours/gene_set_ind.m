function ind = gene_set_ind(name)
if  ischar(name)
    switch lower(name)
        case 'aeroplane'
            ind = 1;
        case 'bike'
            ind = 2;
        case 'bird'
            ind=3;
        case 'boat'
            ind= 4;
        case 'bottle'
            ind = 5;
        case 'bus'
            ind = 6;
        case'car'
            ind=7;
        case'cat'
            ind=8;
        case 'chair'
            ind = 9;
        case'cow'
            ind=10;
        case 'table'
            ind = 11;
        case'dog'
            ind=12;
        case'horse'
            ind=13;
        case'motorbike'
            ind=14;
        case 'person'
            ind= 15;
        case 'plant'
            ind= 16;
        case 'sheep'
            ind= 17;
        case 'sofa'
            ind= 18;
        case 'train'
            ind= 19;
        case 'tv'
            ind= 20;
            
    end
else
    switch lower(name)
        case  1
            ind = 'aeroplane';
        case 2
            ind = 'bike';
        case 3
            ind='bird';
        case 4
            ind= 'boat';
        case 5
            ind= 'bottle';
        case 6
            ind= 'bus';
        case 7
            ind='car';
        case 8
            ind='cat';
        case 9
            ind='chair';
        case 10
            ind='cow';
        case 11
            ind='table';
        case 12
            ind='dog';
        case 13
            ind='horse';
        case 14
            ind= 'motorbike';
        case 15
            ind= 'person';
        case 16
            ind= 'plant';
        case 17
            ind= 'sheep';
        case 18
            ind= 'sofa';
        case 19
            ind='train';
        case 20
            ind= 'tv';
    end
end