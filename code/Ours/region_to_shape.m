function polar_values_descrete=region_to_shape(im_region)
    if nargin==0
        im_region=imread('50.png');
    end
    [region_i region_j]=find(im_region(:,:,1));
    region_i_mean=mean(region_i);
    region_j_mean=mean(region_j);
    region_size=length(region_i);
    region_size_normalize=10000;
    im_edge=edge(im_region);
    [edge_i edge_j]=find(im_edge);
    edge_i=(edge_i-region_i_mean)*region_size_normalize/region_size;
    edge_j=(edge_j-region_j_mean)*region_size_normalize/region_size;
    polar_values=zeros(length(edge_i),2);
    for edge_index=1:length(edge_i)
        polar_values(edge_index,:)=[ij_to_angle(edge_i(edge_index),edge_j(edge_index)) norm([edge_i(edge_index) edge_j(edge_index)])];
    end
    [~, sorted_indexes]=sort(polar_values(:,1));
    polar_values=polar_values(sorted_indexes,:);
    polar_values_descrete=zeros(360,1);
    polar_value_descrete_index=1;
    for polar_value_index=1:size(polar_values,1)-1
        if polar_values(polar_value_index)>polar_value_descrete_index
            polar_values_descrete(polar_value_descrete_index)=polar_values(polar_value_index,2);
            polar_value_descrete_index=polar_value_descrete_index+1;
        end
    end
    if length(polar_values)==0
        polar_values_descrete=40*ones(360,1);
        polar_values(1,:)=[1 40];
    end
    for polar_value_descrete_index=360:-1:1
        if polar_values_descrete(polar_value_descrete_index)==0
            polar_values_descrete(polar_value_descrete_index)=polar_values(end,2);
        end
    end
%     polar_values_descrete = (polar_values_descrete - min(polar_values_descrete))/(max(polar_values_descrete) - min(polar_values_descrete));
%     polar_values_descrete=polar_values_descrete-30;%mean(polar_values_descrete);
%     polar_values_descrete=polar_values_descrete/norm(polar_values_descrete);
%     
end

function ij_angle=ij_to_angle(i,j)
    if (j==0)&&(i>0)
        ij_angle=90;
    elseif (j==0)&&(i<0)
        ij_angle=270;
    elseif (j>0)&&(i==0)
        ij_angle=0;
    elseif (j<0)&&(i==0)
        ij_angle=180;
    elseif (j>0)&&(i>0)
        ij_angle=atand(i/j);
    elseif (j>0)&&(i<0)
        ij_angle=atand(i/j)+360;
    elseif (j<0)&&(i>0)
        ij_angle=atand(i/j)+180;
    elseif (j<0)&&(i<0)
        ij_angle=atand(i/j)+180;
    end
end