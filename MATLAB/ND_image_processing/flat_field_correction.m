function image_corrected = flat_field_correction(image, flat_field, dark_field)

image_corrected = (double(image) - double(dark_field))./...
    (double(flat_field) - double(dark_field));

end
