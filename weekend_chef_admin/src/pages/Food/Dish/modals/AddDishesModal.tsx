import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { baseUrl, baseUrlMedia, userToken } from '../../../../constants';
import Alert2 from '../../../UiElements/Alert2';

const AddDishModal = ({ isOpen, onClose, fetchData, dishCategories }) => {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [basePrice, setBasePrice] = useState('');
  const [photo, setPhoto] = useState(null);
  const [value, setValue] = useState('');
  const [quantity, setQuantity] = useState('');
  const [inputErrors, setInputErrors] = useState({});
  const [serverError, setServerError] = useState({});
  const [loading, setLoading] = useState(false);
  const [alert, setAlert] = useState({ message: '', type: '' });
  const [selectedCategory, setSelectedCategory] = useState(''); // Store the selected category id

  const navigate = useNavigate();

  const closeAlert = () => {
    setAlert({ message: '', type: '' });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    setInputErrors({});
    setServerError({});

    let formValid = true;
    const errors = {};

    // Input validation
    if (name === '') {
      formValid = false;
      errors.name = 'Dish name is required.';
    }

    if (description === '') {
      formValid = false;
      errors.description = 'Description is required.';
    }

    if (basePrice === '') {
      formValid = false;
      errors.basePrice = 'Base price is required.';
    }
    if (value === '') {
      formValid = false;
      errors.value = 'Value is required.';
    }
    if (quantity === '') {
      formValid = false;
      errors.quantity = 'Quantity is required.';
    }

    if (selectedCategory === '') {
      formValid = false;
      errors.category = 'Category is required.';
    }

    if (!photo) {
      formValid = false;
      errors.photo = 'Food photo is required.';
    }

    if (!formValid) {
      setInputErrors(errors);
      return;
    }

    const formData = new FormData();
    formData.append('name', name);
    formData.append('description', description);
    formData.append('base_price', basePrice);
    formData.append('category_id', selectedCategory);
    formData.append('value', value);
    formData.append('quantity', quantity);
    formData.append('cover_photo', photo);

    const url = baseUrl + 'api/food/add-dish/';

    try {
      setLoading(true);

      // Ensure the token is retrieved correctly (log for debugging)
      console.log('Authorization Token:', userToken); // Debugging line

      const response = await fetch(url, {
        method: 'POST',
        body: formData,
        headers: {
          // Add Authorization token in headers if available
          Authorization: `Token ${userToken}`, // Ensure correct format (Bearer or Token)
        },
      });

      const data = await response.json();

      if (!response.ok) {
        setServerError(data);
        throw new Error(data.message || 'Failed to add dish');
      }

      console.log('Dish added successfully');

      // Close the modal and navigate to the All Dish Categories page
      onClose(); // Close the modal
      fetchData();
      setName('');
      setDescription('');
      setBasePrice('');
      setValue('');
      setQuantity('');
      setPhoto(null);

      setAlert({ message: 'Item added successfully', type: 'success' });
    } catch (error) {
      // Check if error response contains validation errors
      if (error?.response?.errors) {
        // Update the form's input errors state with server-side validation errors
        setInputErrors(error.response.errors);
      } else {
        // For any other type of error (network issues, unexpected errors, etc.)
        setAlert({
          message: 'An error occurred while adding the item',
          type: 'error',
        });
        console.error('Error adding dish:', error);
      }
    } finally {
      setLoading(false);
    }
  };

  // Handle image preview
  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setPhoto(file);
    }
  };

  const imagePreview = photo ? URL.createObjectURL(photo) : null;

  const handleCategoryChange = (event) => {
    setSelectedCategory(event.target.value);
  };

    // Handle close when clicking outside the modal
    const handleBackdropClick = (e) => {
      if (e.target === e.currentTarget) {
        onClose(); // Close modal when backdrop is clicked
      }
    };
  return (
    isOpen && (
      <div
        className={`fixed inset-0 flex items-center justify-end z-999 bg-black bg-opacity-50 transition-opacity duration-300 ease-in ${
          isOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'
        }`}
      
        onClick={handleBackdropClick}

      >
        <div
          className={`bg-white rounded-lg p-6 shadow-lg max-w-3xl w-full h-full flex justify-center overflow-auto transition-all duration-500 ease-in-out transform ${
            isOpen
              ? 'scale-100 translate-y-0'
              : 'scale-95 translate-y-4 opacity-0'
          }`}
        >
          <div className="w-full max-w-3xl h-full flex flex-col">
            <h1 className="text-xl font-semibold mb-3">Add Dish</h1>

            {/* Scrollable container */}
            <div className="overflow-y-auto h-full flex-1">
              <form onSubmit={handleSubmit} className="w-full max-w-3xl">
                {/* Name */}
                <div className="mb-5.5">
                  <label
                    className="mb-3 block text-sm font-medium text-black dark:text-white"
                    htmlFor="name"
                  >
                    Dish Name
                  </label>
                  <input
                    className={`w-full rounded border ${
                      inputErrors.name ? 'border-red-500' : 'border-stroke'
                    } bg-gray py-3 pl-5 pr-4.5 text-black focus:border-primary focus-visible:outline-none dark:border-strokedark dark:bg-meta-4 dark:text-white dark:focus:border-primary`}
                    id="name"
                    name="name"
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Soups"
                  />
                  {inputErrors.name && (
                    <p className="text-red-500 text-sm mt-1">
                      {inputErrors.name}
                    </p>
                  )}
                </div>

                {/* Description */}
                <div className="mb-5.5">
                  <label
                    className="mb-3 block text-sm font-medium text-black dark:text-white"
                    htmlFor="description"
                  >
                    Description
                  </label>
                  <textarea
                    className={`w-full rounded border ${
                      inputErrors.description
                        ? 'border-red-500'
                        : 'border-stroke'
                    } bg-gray py-3 pl-5 pr-4.5 text-black focus:border-primary focus-visible:outline-none dark:border-strokedark dark:bg-meta-4 dark:text-white dark:focus:border-primary`}
                    id="description"
                    name="description"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    rows={4}
                    placeholder="Dish description"
                  ></textarea>
                  {inputErrors.description && (
                    <p className="text-red-500 text-sm mt-1">
                      {inputErrors.description}
                    </p>
                  )}
                </div>

                {/* Value */}
                <div className="mb-5.5">
                  <label
                    className="mb-3 block text-sm font-medium text-black dark:text-white"
                    htmlFor="value"
                  >
                    Value
                  </label>
                  <input
                    className={`w-full rounded border ${
                      inputErrors.value ? 'border-red-500' : 'border-stroke'
                    } bg-gray py-3 pl-5 pr-4.5 text-black focus:border-primary focus-visible:outline-none dark:border-strokedark dark:bg-meta-4 dark:text-white dark:focus:border-primary`}
                    id="value"
                    name="value"
                    type="text"
                    value={value}
                    onChange={(e) => setValue(e.target.value)}
                    placeholder="34 kg"
                  />
                  {inputErrors.value && (
                    <p className="text-red-500 text-sm mt-1">
                      {inputErrors.value}
                    </p>
                  )}
                </div>

                {/* Quantity */}
                <div className="mb-5.5">
                  <label
                    className="mb-3 block text-sm font-medium text-black dark:text-white"
                    htmlFor="quantity"
                  >
                    Quantity
                  </label>
                  <input
                    className={`w-full rounded border ${
                      inputErrors.quantity ? 'border-red-500' : 'border-stroke'
                    } bg-gray py-3 pl-5 pr-4.5 text-black focus:border-primary focus-visible:outline-none dark:border-strokedark dark:bg-meta-4 dark:text-white dark:focus:border-primary`}
                    id="quantity"
                    name="quantity"
                    type="text"
                    value={quantity}
                    onChange={(e) => setQuantity(e.target.value)}
                    placeholder="2"
                  />
                  {inputErrors.quantity && (
                    <p className="text-red-500 text-sm mt-1">
                      {inputErrors.quantity}
                    </p>
                  )}
                </div>

                {/* Base price */}
                <div className="mb-5.5">
                  <label
                    className="mb-3 block text-sm font-medium text-black dark:text-white"
                    htmlFor="baseprice"
                  >
                    Base price (Ghc)
                  </label>
                  <input
                    className={`w-full rounded border ${
                      inputErrors.basePrice ? 'border-red-500' : 'border-stroke'
                    } bg-gray py-3 pl-5 pr-4.5 text-black focus:border-primary focus-visible:outline-none dark:border-strokedark dark:bg-meta-4 dark:text-white dark:focus:border-primary`}
                    id="basePrice"
                    name="basePrice"
                    type="text"
                    value={basePrice}
                    onChange={(e) => setBasePrice(e.target.value)}
                    placeholder="20"
                  />
                  {inputErrors.basePrice && (
                    <p className="text-red-500 text-sm mt-1">
                      {inputErrors.basePrice}
                    </p>
                  )}
                </div>
{/* Category */}
<div className="flex flex-col gap-5 mb-7">
  <label
    className="block text-sm font-medium text-black dark:text-white"
    htmlFor="category"
  >
    Category
  </label>

  {loading ? (
    <div>Loading...</div>
  ) : (
    <div className="relative z-20 bg-white dark:bg-form-input">
      {/* Select Dropdown Wrapper */}
      <select
        id="category"
        name="category"
        value={selectedCategory}
        onChange={handleCategoryChange}
        className={`w-full appearance-none rounded border ${
          inputErrors.category ? 'border-red-500' : 'border-stroke'
        } bg-gray py-3 pl-5 pr-10 text-black focus:border-primary focus-visible:outline-none dark:border-strokedark dark:bg-meta-4 dark:text-white dark:focus:border-primary`}
      >
        <option value="" disabled className="text-body dark:text-bodydark">
          Select a Category
        </option>
        {dishCategories.map((category) => (
          <option
            key={category.id}
            value={category.id}
            className="text-body dark:text-bodydark"
          >
            {category.name}
          </option>
        ))}
      </select>

      {/* Dropdown Icon */}
      <svg
        className="absolute right-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-500 dark:text-white pointer-events-none"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth="2"
          d="M19 9l-7 7-7-7"
        />
      </svg>

      {/* Error message */}
      {inputErrors.category && (
        <p className="text-red-500 text-sm mt-1">
          {inputErrors.category}
        </p>
      )}
    </div>
  )}
</div>



                {/* Photo Upload */}
                <div className="mb-5.5">
                  <label
                    className="mb-3 block text-sm font-medium text-black dark:text-white"
                    htmlFor="photo"
                  >
                    Dish Photo
                  </label>
                  <input
                    className={`w-full rounded border ${
                      inputErrors.photo ? 'border-red-500' : 'border-stroke'
                    } bg-gray py-3 pl-5 pr-4.5 text-black focus:border-primary focus-visible:outline-none dark:border-strokedark dark:bg-meta-4 dark:text-white dark:focus:border-primary`}
                    id="photo"
                    name="photo"
                    type="file"
                    accept="image/*"
                    onChange={handleImageChange}
                  />
                  {inputErrors.photo && (
                    <p className="text-red-500 text-sm mt-1">
                      {inputErrors.photo}
                    </p>
                  )}

                  {/* Image Preview */}
                  {imagePreview && (
                    <div className="mt-3">
                      <img
                        src={imagePreview}
                        alt="Dish Preview"
                        className="w-32 h-32 object-cover rounded-lg"
                      />
                    </div>
                  )}
                </div>

                {/* Server Error */}
                {serverError && serverError.errors && (
                  <div className="mb-4 p-4 bg-red-100 border-l-4 border-red-500 text-red-600 rounded-lg flex flex-col space-y-2">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      className="w-5 h-5 text-red-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        d="M12 8v4m0 4h.01M5.303 5.303a9 9 0 1112.394 12.394 9 9 0 01-12.394-12.394z"
                      />
                    </svg>

                    {/* Dynamically render errors */}
                    {serverError.errors &&
                      Object.keys(serverError.errors).map((field) => (
                        <div key={field}>
                          <p className="text-red-500 text-sm">
                            {Array.isArray(serverError.errors[field])
                              ? serverError.errors[field].join(', ') // Join array of error messages if any
                              : serverError.errors[field]}
                          </p>
                        </div>
                      ))}
                  </div>
                )}

                {/* Buttons */}
                <div className="flex justify-end gap-4.5">
                  <button
                    type="button"
                    onClick={onClose}
                    className="flex justify-center rounded border border-stroke py-2 px-6 font-medium text-black hover:shadow-1 dark:border-strokedark dark:text-white"
                  >
                    Cancel
                  </button>

                  {loading ? (
                    <div
                      role="status"
                      className="flex flex-col items-center justify-center h-full space-y-4"
                    >
                      <svg
                        aria-hidden="true"
                        className="w-8 h-8 text-gray-200 animate-spin dark:text-gray-600 fill-green"
                        viewBox="0 0 100 101"
                        fill="none"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path
                          d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                          fill="currentColor"
                        />
                        <path
                          d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0871 9.04874 41.5916 10.4971 44.0171 9.86006C47.3133 8.99412 50.7687 8.51414 54.2369 8.54135C59.2411 8.57677 64.1174 10.2351 68.5077 12.9588C72.6234 15.5377 76.2763 19.2303 79.2085 23.5668C82.7227 28.7998 85.2346 34.6957 87.5305 41.0168C88.1714 42.7039 91.2973 41.4942 93.9676 39.0409Z"
                          fill="currentFill"
                        />
                      </svg>
                      <span className="text-green">Loading...</span>
                    </div>
                  ) : (
                    <button
                      className="flex justify-center rounded bg-primary py-2 px-6 font-medium text-gray hover:bg-opacity-90"
                      type="submit"
                    >
                      Save & Continue
                    </button>
                  )}
                </div>



              </form>


              
            </div>
          </div>
        </div>
      </div>
    )
  );
};

export default AddDishModal;
