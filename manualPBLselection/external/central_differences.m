function grad_field = central_differences(F,dx)

grad_field = zeros(size(F));

for j=1:size(F,2)
    grad_field(:,j) = conv(F(:,j),1/(2*dx)*[1;0;-1],'same');
end

