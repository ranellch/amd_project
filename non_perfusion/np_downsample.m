function [instance_matrix, label_vector] = np_downsample(instance_matrix, label_vector, fraction_pos)
    %Try to get at least fraction_pos positive instances by discarding a certain
    %   number of negatives
    negative_label = 0;
    positive_label = 1;
    
    numneg = sum(label_vector==negative_label);
    numpos = sum(label_vector==positive_label);
   
    if numpos/(numneg+numpos) < fraction_pos
        numdiscard = numneg - (numpos * (1-fraction_pos) / fraction_pos);
        discard_count = 0;
        
        discard_vector = zeros(length(label_vector),1);
        indices = randperm(length(label_vector),length(label_vector));
        
        for i = indices
            if label_vector(i) == negative_label 
                discard_vector(i) = 1;
                discard_count = discard_count + 1;
            end
            if discard_count >= numdiscard
                break
            end
        end
        
        discard_vector = logical(discard_vector);
        label_vector(discard_vector) = [];
        instance_matrix(discard_vector,:) = [];
    end
end