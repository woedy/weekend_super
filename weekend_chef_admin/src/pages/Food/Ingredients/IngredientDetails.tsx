import { useCallback, useEffect, useState } from 'react';
import Breadcrumb from '../../../components/Breadcrumbs/Breadcrumb';
import { baseUrl, baseUrlMedia, userToken } from '../../../constants';
import { useParams } from 'react-router-dom';
import EditIngredientModal from './modals/EditIngredientModal';

const IngredientDetails = () => {
  const { ingredient_id } = useParams();

  const [loading, setLoading] = useState(false);
  const [ingredientDetails, setIngredientDetails] = useState({});


  const [isEditModalOpen, setIsEditModalOpen] = useState(false);



  const openEditItemModal = () => {
    setIsEditModalOpen(true);
  };

  const closeEditItemModal = () => {
    setIsEditModalOpen(false);
  };

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetch(
        `${baseUrl}api/food/get-ingredient-details/?ingredient_id=${encodeURIComponent(
          ingredient_id,
        )}`,
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
      setIngredientDetails(data.data);

    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  }, [baseUrl, ingredient_id, userToken]);



  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return (
    <div>
      <Breadcrumb pageName="Ingredients / Details" />

      <div className="grid grid-cols-3 gap-2">
        <div className="col-span-2 rounded-sm border border-stroke  shadow-default dark:border-strokedark dark:bg-boxdark">
          <div className="container mx-auto">
          <div className=" shadow-lg rounded-lg p-6">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-semibold text-gray-900 dark:text-white">
            {ingredientDetails.name} - <sapn className="text-lg text-primary font-normal">{ingredientDetails.category}</sapn>
          </h2>
          {/* Status Tag */}
          <span
            className={`px-3 py-1 text-xs font-semibold rounded-full ${
              ingredientDetails.active ? 'bg-green-200 text-green-800' : 'bg-red-200 text-red-800'
            }`}
          >
            {ingredientDetails.active ? 'Active' : 'Inactive'}
          </span>
        </div>

        {/* Image and Description */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="flex justify-center">
            <img
                          src={`${baseUrlMedia}${ingredientDetails.photo}`}
                          alt={ingredientDetails.name}
              className="w-full h-64 object-cover rounded-lg shadow-md"
            />
          </div>
          <div className="flex flex-col justify-between">
            <p className="text-gray-700 dark:text-gray-300">{ingredientDetails.description}</p>
            <p className="text-sm text-gray-500 mt-2">Created on: {new Date(ingredientDetails.created_at).toLocaleDateString()}</p>
            <p className="text-sm text-gray-500">Last updated: {new Date(ingredientDetails.updated_at).toLocaleDateString()}</p>
          </div>
        </div>

        {/* Pricing and Quantity */}
        <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="flex flex-col">
            <span className="text-lg font-semibold text-gray-800 dark:text-white">Price</span>
            <p className="text-xl text-gray-900 dark:text-gray-100">
              Ghc {ingredientDetails.price}
            </p>
          </div>

          <div className="flex flex-col">
            <span className="text-lg font-semibold text-gray-800 dark:text-white">Quantity</span>
            <p className="text-xl text-gray-900 dark:text-gray-100">
              {ingredientDetails.quantity}
            </p>
          </div>

          <div className="flex flex-col">
            <span className="text-lg font-semibold text-gray-800 dark:text-white">Value</span>
            <p className="text-xl  text-gray-900 dark:text-gray-100">
              {ingredientDetails.value}
            </p>
          </div>
        </div>

        {/* Additional Information */}
        <div className="mt-6">
          <h3 className="text-xl font-semibold text-gray-800 dark:text-white mb-2">Additional Information</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="flex flex-col">
              <span className="text-gray-500 font-semibold">Ingredient ID</span>
              <p className="text-gray-800 dark:text-white">{ingredientDetails.ingredient_id}</p>
            </div>
            <div className="flex flex-col">
              <span className="text-gray-500 font-semibold">Unit</span>
              <p className="text-gray-800 dark:text-white">{ingredientDetails.unit ? ingredientDetails.unit : 'N/A'}</p>
            </div>
          </div>
        </div>
      </div>

          </div>
        </div>

        <div className="col-span-1 rounded-sm border border-stroke  shadow-default dark:border-strokedark dark:bg-boxdark">
          <button
            className="bg-primary m-5  h-7 text-white px-4 text-sm py-1 rounded-2xl"
            onClick={openEditItemModal}
          >
            Edit Ingredient
          </button>

          {/* AddItemModal to display the Item form */}
          <EditIngredientModal
            isOpen={isEditModalOpen}
            onClose={closeEditItemModal}
            fetchData={fetchData}
            ingredientDetails={ingredientDetails}
            ingredient_id={ingredient_id}
          />
        </div>
      </div>




      <div className="container mx-auto p-6">
 
    </div>
  







    </div>
  );
};

export default IngredientDetails;

