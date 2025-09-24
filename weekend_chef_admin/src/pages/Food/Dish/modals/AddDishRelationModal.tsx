import { useCallback, useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { baseUrl, baseUrlMedia, userToken } from '../../../../constants';
import Pagination from '../../../../components/Pagination';

const AddDishRelationModal = ({ isOpen, onClose, fetchData, dish_id }) => {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [dishes, setDishes] = useState([]);
  const [dishCategories, setDishCategories] = useState([]);
  const [totalPages, setTotalPages] = useState(1); // Default to 1 to avoid issues

  const [inputErrors, setInputErrors] = useState({});
  const [serverError, setServerError] = useState({});
  const [loading, setLoading] = useState(false);
  const [alert, setAlert] = useState({ message: '', type: '' });

  const [selectedOptions, setSelectedOptions] = useState([]);
  const [checkedCategories, setCheckedCategories] = useState({});

  // Function to handle selection of options
  const handleOptionChange = (e, optionId) => {
    if (e.target.checked) {
      // Add the option ID to the selected options array
      setSelectedOptions((prevSelected) => [...prevSelected, optionId]);
    } else {
      // Remove the option ID from the selected options array
      setSelectedOptions((prevSelected) =>
        prevSelected.filter((id) => id !== optionId),
      );
    }
  };

  const fetchInitData = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetch(
        `${baseUrl}api/food/get-all-dishes/?search=${encodeURIComponent(
          search,
        )}&page=${page}&categories=${JSON.stringify(checkedCategories)}`,
        {
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Token ${userToken}`,
          },
        },
      );

      if (!response.ok) {
        throw new Error('Network response was not ok');
      }

      const data = await response.json();
      setDishes(data.data.dishes);
      setTotalPages(data.data.pagination.total_pages);
      console.log('Total Pages:', data.data.pagination.total_pages);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  }, [baseUrl, search, page, userToken, checkedCategories]);

  

  useEffect(() => {
    fetchInitData();
  }, [fetchInitData, search, page]);







  const handleSubmit = async (e) => {
    e.preventDefault();

    setInputErrors({});
    setServerError({});

    let formValid = true;
    const errors = {};

    // If no options are selected, show an error message
    if (selectedOptions.length === 0) {
      formValid = false;
      errors.options = 'At least one option must be selected.';
    }

    if (!formValid) {
      setInputErrors(errors);
      return;
    }

    // Prepare data to send as JSON
    const dataToSend = {
      dish_id: dish_id,
      related_food: selectedOptions, // Send options as an array
    };

    const url = baseUrl + 'api/food/add-related-food-list/';

    try {
      setLoading(true);

      // Send POST request with JSON body
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          Authorization: `Token ${userToken}`,
          'Content-Type': 'application/json', // Indicate that we are sending JSON
        },
        body: JSON.stringify(dataToSend), // Serialize data as JSON
      });

      const data = await response.json();

      if (!response.ok) {
        setServerError(data);
        throw new Error(data.message || 'Failed to add option');
      }

      console.log('Dish added successfully');

      // Reset the modal and refresh data
      onClose();
      fetchData();
      setAlert({ message: 'Item added successfully', type: 'success' });
    } catch (error) {
      setAlert({
        message: 'An error occurred while adding the item',
        type: 'error',
      });
      console.error('Error adding option:', error);
    } finally {
      setLoading(false);
    }
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
            <h1 className="text-xl font-semibold mb-3">
              Add Related Food
            </h1>

            {/* Scrollable container */}
            <div className="overflow-y-auto h-full flex-1">
              <form onSubmit={handleSubmit} className="w-full max-w-3xl">
                {/* Search */}
                <div className="mb-5.5">
                  <input
                    className={`w-full rounded border border-stroke bg-gray py-3 pl-5 pr-4.5 text-black focus:border-primary focus-visible:outline-none dark:border-strokedark dark:bg-meta-4 dark:text-white dark:focus:border-primary`}
                    id="search"
                    name="search"
                    type="text"
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    placeholder="Search..."
                  />
                </div>

                <div className="grid grid-cols-6 border-t border-stroke py-4.5 px-4 dark:border-strokedark sm:grid-cols-6 md:px-6 2xl:px-7.5">
                  <div className="col-span-1 flex items-center">
                    <p className="font-medium">Name</p>
                  </div>

                  <div className="col-span-1 hidden items-center sm:flex mr-4">
                    <p className="font-medium">Price</p>
                  </div>

                  <div className="col-span-1 hidden items-center sm:flex mr-4">
                    <p className="font-medium">Value</p>
                  </div>
                </div>

             {dishes
               ? dishes.map((dish) => (
                   <div
                     className="grid grid-cols-6 border-t border-stroke py-4.5 px-4 dark:border-strokedark sm:grid-cols-6 md:px-6 2xl:px-7.5 hover:bg-gray"
                     key={dish.dish_id}
                   >
     
     
     
                     <div className="col-span-1 flex items-center">
                       <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                         <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                           <div className="h-12 w-12 overflow-hidden rounded-md">
                             <img
                               src={`${baseUrlMedia}${dish.cover_photo}`}
                               alt="dish"
                               className="h-full w-full object-cover"
                             />
                           </div>
                         </div>
                         <p className="text-sm text-black dark:text-white">
                           {`${dish.name}`}
                         </p>
                       </div>
                     </div>
       
        
       
     
                     <div className="col-span-1 hidden items-center sm:flex mr-4">
                       <p className="text-sm text-black dark:text-white">
                         {dish.base_price}
                       </p>
                     </div>
     
     
                     <div className="col-span-1 hidden items-center sm:flex mr-4">
                       <p className="text-sm text-black dark:text-white">
                         {dish.value}
                       </p>
                     </div>
       
       
       
                               {/* Add a checkbox to select options */}
                               <div className="col-span-1 flex items-center justify-end">
                        <input
                          type="checkbox"
                          id={`option-${dish.dish_id}`}
                          value={dish.dish_id}
                          onChange={(e) =>
                            handleOptionChange(e, dish.dish_id)
                          }
                        />
                      </div>
                   </div>
                 ))
               : null}
     
                <Pagination
                  pagination={{
                    page_number: page,
                    total_pages: totalPages,
                    next: page < totalPages ? page + 1 : null,
                    previous: page > 1 ? page - 1 : null,
                  }}
                  setPage={setPage}
                />

                {inputErrors.options && (
                  <p className="text-red-500 text-sm">{inputErrors.options}</p>
                )}

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

export default AddDishRelationModal;
