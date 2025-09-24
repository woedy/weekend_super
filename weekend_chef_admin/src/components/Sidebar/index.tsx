import React, { useEffect, useRef, useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import SidebarLinkGroup from './SidebarLinkGroup';
import Logo from '../../images/logo/weekend_logo2.png';

interface SidebarProps {
  sidebarOpen: boolean;
  setSidebarOpen: (arg: boolean) => void;
}

const Sidebar = ({ sidebarOpen, setSidebarOpen }: SidebarProps) => {
  const location = useLocation();
  const { pathname } = location;

  const trigger = useRef<any>(null);
  const sidebar = useRef<any>(null);

  const storedSidebarExpanded = localStorage.getItem('sidebar-expanded');
  const [sidebarExpanded, setSidebarExpanded] = useState(
    storedSidebarExpanded === null ? false : storedSidebarExpanded === 'true',
  );

  // close on click outside
  useEffect(() => {
    const clickHandler = ({ target }: MouseEvent) => {
      if (!sidebar.current || !trigger.current) return;
      if (
        !sidebarOpen ||
        sidebar.current.contains(target) ||
        trigger.current.contains(target)
      )
        return;
      setSidebarOpen(false);
    };
    document.addEventListener('click', clickHandler);
    return () => document.removeEventListener('click', clickHandler);
  });

  // close if the esc key is pressed
  useEffect(() => {
    const keyHandler = ({ keyCode }: KeyboardEvent) => {
      if (!sidebarOpen || keyCode !== 27) return;
      setSidebarOpen(false);
    };
    document.addEventListener('keydown', keyHandler);
    return () => document.removeEventListener('keydown', keyHandler);
  });

  useEffect(() => {
    localStorage.setItem('sidebar-expanded', sidebarExpanded.toString());
    if (sidebarExpanded) {
      document.querySelector('body')?.classList.add('sidebar-expanded');
    } else {
      document.querySelector('body')?.classList.remove('sidebar-expanded');
    }
  }, [sidebarExpanded]);

  return (
    <aside
      ref={sidebar}
      className={`absolute left-0 top-0 z-9999 flex h-screen w-72.5 flex-col overflow-y-hidden bg-primary duration-300 ease-linear dark:bg-boxdark lg:static lg:translate-x-0 ${
        sidebarOpen ? 'translate-x-0' : '-translate-x-full'
      }`}
    >
      {/* <!-- SIDEBAR HEADER --> */}
      <div className="flex items-center justify-between gap-2 px-6 py-5.5 lg:py-6.5">
        <NavLink to="/dashboard">
          <div className="flex items-center gap-2">
            <img className="h-10" src={Logo} alt="Logo" />
            <h4 className="mb-2 text-xl font-semibold text-white dark:text-white">
              Weekend Chef Admin
            </h4>
          </div>
        </NavLink>

        <button
          ref={trigger}
          onClick={() => setSidebarOpen(!sidebarOpen)}
          aria-controls="sidebar"
          aria-expanded={sidebarOpen}
          className="block lg:hidden"
        >
          <svg
            className="fill-current"
            width="20"
            height="18"
            viewBox="0 0 20 18"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M19 8.175H2.98748L9.36248 1.6875C9.69998 1.35 9.69998 0.825 9.36248 0.4875C9.02498 0.15 8.49998 0.15 8.16248 0.4875L0.399976 8.3625C0.0624756 8.7 0.0624756 9.225 0.399976 9.5625L8.16248 17.4375C8.31248 17.5875 8.53748 17.7 8.76248 17.7C8.98748 17.7 9.17498 17.625 9.36248 17.475C9.69998 17.1375 9.69998 16.6125 9.36248 16.275L3.02498 9.8625H19C19.45 9.8625 19.825 9.4875 19.825 9.0375C19.825 8.55 19.45 8.175 19 8.175Z"
              fill=""
            />
          </svg>
        </button>
      </div>
      {/* <!-- SIDEBAR HEADER --> */}

      <div className="no-scrollbar flex flex-col overflow-y-auto duration-300 ease-linear">
        {/* <!-- Sidebar Menu --> */}
        <nav className="mt-5 py-4 px-4 lg:mt-9 lg:px-6">
          {/* <!-- Menu Group --> */}
          <div>
            <h3 className="mb-4 ml-4 text-sm font-semibold text-bodydark2">
              MENU
            </h3>

            <ul className="mb-6 flex flex-col gap-1.5">
              {/* <!-- Menu Item Dashboard --> */}
              <li>
                <NavLink
                  to="/dashboard"
                  className={({ isActive }) =>
                    `group relative flex items-center gap-2.5 rounded-sm py-2 px-4 font-medium ${
                      isActive
                        ? 'bg-yellow text-black dark:bg-meta-4 dark:text-white'
                        : 'text-bodydark1 hover:bg-yellow hover:text-black dark:hover:bg-white'
                    } duration-300 ease-in-out`
                  }
                >
                  <svg
                    className="fill-current"
                    width="18"
                    height="18"
                    viewBox="0 0 18 18"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M6.10322 0.956299H2.53135C1.5751 0.956299 0.787598 1.7438 0.787598 2.70005V6.27192C0.787598 7.22817 1.5751 8.01567 2.53135 8.01567H6.10322C7.05947 8.01567 7.84697 7.22817 7.84697 6.27192V2.72817C7.8751 1.7438 7.0876 0.956299 6.10322 0.956299ZM6.60947 6.30005C6.60947 6.5813 6.38447 6.8063 6.10322 6.8063H2.53135C2.2501 6.8063 2.0251 6.5813 2.0251 6.30005V2.72817C2.0251 2.44692 2.2501 2.22192 2.53135 2.22192H6.10322C6.38447 2.22192 6.60947 2.44692 6.60947 2.72817V6.30005Z"
                      fill=""
                    />
                    <path
                      d="M15.4689 0.956299H11.8971C10.9408 0.956299 10.1533 1.7438 10.1533 2.70005V6.27192C10.1533 7.22817 10.9408 8.01567 11.8971 8.01567H15.4689C16.4252 8.01567 17.2127 7.22817 17.2127 6.27192V2.72817C17.2127 1.7438 16.4252 0.956299 15.4689 0.956299ZM15.9752 6.30005C15.9752 6.5813 15.7502 6.8063 15.4689 6.8063H11.8971C11.6158 6.8063 11.3908 6.5813 11.3908 6.30005V2.72817C11.3908 2.44692 11.6158 2.22192 11.8971 2.22192H15.4689C15.7502 2.22192 15.9752 2.44692 15.9752 2.72817V6.30005Z"
                      fill=""
                    />
                    <path
                      d="M6.10322 9.92822H2.53135C1.5751 9.92822 0.787598 10.7157 0.787598 11.672V15.2438C0.787598 16.2001 1.5751 16.9876 2.53135 16.9876H6.10322C7.05947 16.9876 7.84697 16.2001 7.84697 15.2438V11.7001C7.8751 10.7157 7.0876 9.92822 6.10322 9.92822ZM6.60947 15.272C6.60947 15.5532 6.38447 15.7782 6.10322 15.7782H2.53135C2.2501 15.7782 2.0251 15.5532 2.0251 15.272V11.7001C2.0251 11.4188 2.2501 11.1938 2.53135 11.1938H6.10322C6.38447 11.1938 6.60947 11.4188 6.60947 11.7001V15.272Z"
                      fill=""
                    />
                    <path
                      d="M15.4689 9.92822H11.8971C10.9408 9.92822 10.1533 10.7157 10.1533 11.672V15.2438C10.1533 16.2001 10.9408 16.9876 11.8971 16.9876H15.4689C16.4252 16.9876 17.2127 16.2001 17.2127 15.2438V11.7001C17.2127 10.7157 16.4252 9.92822 15.4689 9.92822ZM15.9752 15.272C15.9752 15.5532 15.7502 15.7782 15.4689 15.7782H11.8971C11.6158 15.7782 11.3908 15.5532 11.3908 15.272V11.7001C11.3908 11.4188 11.6158 11.1938 11.8971 11.1938H15.4689C15.7502 11.1938 15.9752 11.4188 15.9752 11.7001V15.272Z"
                      fill=""
                    />
                  </svg>
                  Dashboard
                </NavLink>
              </li>

              {/* <!-- Menu Item Dashboard --> */}

              {/* <!-- Menu Item Forms --> */}
              <SidebarLinkGroup
                activeCondition={
                  pathname === '/food_menus' || pathname.includes('food_menus')
                }
              >
                {(handleClick, open) => {
                  return (
                    <React.Fragment>
                      <NavLink
                        to="#"
                        className={`group relative flex items-center gap-2.5 rounded-sm py-2 px-4 font-medium text-bodydark1 duration-300 ease-in-out hover:bg-white hover:text-black dark:hover:bg-meta-4 ${
                          (pathname === '/food_menus' ||
                            pathname.includes('food_menu')) &&
                          'bg-graydark dark:bg-meta-4'
                        }`}
                        onClick={(e) => {
                          e.preventDefault();
                          sidebarExpanded
                            ? handleClick()
                            : setSidebarExpanded(true);
                        }}
                      >
                        <svg
                          className="fill-current"
                          width="18"
                          height="18"
                          viewBox="0 0 18 18"
                          fill="none"
                          xmlns="http://www.w3.org/2000/svg"
                        >
                          <path
                            d="M1.43425 7.5093H2.278C2.44675 7.5093 2.55925 7.3968 2.58737 7.31243L2.98112 6.32805H5.90612L6.27175 7.31243C6.328 7.48118 6.46862 7.5093 6.58112 7.5093H7.453C7.76237 7.48118 7.87487 7.25618 7.76237 7.03118L5.428 1.4343C5.37175 1.26555 5.3155 1.23743 5.14675 1.23743H3.88112C3.76862 1.23743 3.59987 1.29368 3.57175 1.4343L1.153 7.08743C1.0405 7.2843 1.20925 7.5093 1.43425 7.5093ZM4.47175 2.98118L5.3155 5.17493H3.59987L4.47175 2.98118Z"
                            fill=""
                          />
                          <path
                            d="M10.1249 2.5031H16.8749C17.2124 2.5031 17.5218 2.22185 17.5218 1.85623C17.5218 1.4906 17.2405 1.20935 16.8749 1.20935H10.1249C9.7874 1.20935 9.47803 1.4906 9.47803 1.85623C9.47803 2.22185 9.75928 2.5031 10.1249 2.5031Z"
                            fill=""
                          />
                          <path
                            d="M16.8749 6.21558H10.1249C9.7874 6.21558 9.47803 6.49683 9.47803 6.86245C9.47803 7.22808 9.75928 7.50933 10.1249 7.50933H16.8749C17.2124 7.50933 17.5218 7.22808 17.5218 6.86245C17.5218 6.49683 17.2124 6.21558 16.8749 6.21558Z"
                            fill=""
                          />
                          <path
                            d="M16.875 11.1656H1.77187C1.43438 11.1656 1.125 11.4469 1.125 11.8125C1.125 12.1781 1.40625 12.4594 1.77187 12.4594H16.875C17.2125 12.4594 17.5219 12.1781 17.5219 11.8125C17.5219 11.4469 17.2125 11.1656 16.875 11.1656Z"
                            fill=""
                          />
                          <path
                            d="M16.875 16.1156H1.77187C1.43438 16.1156 1.125 16.3969 1.125 16.7625C1.125 17.1281 1.40625 17.4094 1.77187 17.4094H16.875C17.2125 17.4094 17.5219 17.1281 17.5219 16.7625C17.5219 16.3969 17.2125 16.1156 16.875 16.1156Z"
                            fill="white"
                          />
                        </svg>
                        Food Menu
                        <svg
                          className={`absolute right-4 top-1/2 -translate-y-1/2 fill-current ${
                            open && 'rotate-180'
                          }`}
                          width="20"
                          height="20"
                          viewBox="0 0 20 20"
                          fill="none"
                          xmlns="http://www.w3.org/2000/svg"
                        >
                          <path
                            fillRule="evenodd"
                            clipRule="evenodd"
                            d="M4.41107 6.9107C4.73651 6.58527 5.26414 6.58527 5.58958 6.9107L10.0003 11.3214L14.4111 6.91071C14.7365 6.58527 15.2641 6.58527 15.5896 6.91071C15.915 7.23614 15.915 7.76378 15.5896 8.08922L10.5896 13.0892C10.2641 13.4147 9.73651 13.4147 9.41107 13.0892L4.41107 8.08922C4.08563 7.76378 4.08563 7.23614 4.41107 6.9107Z"
                            fill=""
                          />
                        </svg>
                      </NavLink>
                      {/* <!-- Dropdown Menu Start --> */}
                      <div
                        className={`translate transform overflow-hidden ${
                          !open && 'hidden'
                        }`}
                      >
                        <ul className="mt-4 mb-5.5 flex flex-col gap-2.5 pl-6">
                          <li>
                            <NavLink
                              to="/all-dish-categories"
                              className={({ isActive }) =>
                                `group relative flex items-center gap-2.5 rounded-sm py-2 px-4 font-medium ${
                                  isActive
                                    ? 'bg-yellow text-black dark:bg-meta-4 dark:text-white'
                                    : 'text-bodydark1 hover:bg-yellow hover:text-black dark:hover:bg-meta-4'
                                } duration-300 ease-in-out`
                              }
                            >
                              <svg
                                fill="none"
                                id="Capa_1"
                                className="fill-current"
                                width="18"
                                height="18"
                                xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 44.979 44.979"
                              >
                                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                                <g
                                  id="SVGRepo_tracerCarrier"
                                  stroke-linecap="round"
                                  stroke-linejoin="round"
                                ></g>
                                <g id="SVGRepo_iconCarrier">
                                  {' '}
                                  <g>
                                    {' '}
                                    <g>
                                      {' '}
                                      <path d="M28.502,17.371c-0.002,0-11.213-0.004-12.011-0.004c0,0-0.005,0-0.006,0c-1.021,0-1.853,0.846-1.85,1.867l0.04,11.565 c0.004,1.018,0.83,1.863,1.845,1.863c0.002,0,0.005,0,0.007,0c0.574,0,1.086-0.287,1.423-0.701l0.729,11.256 c0.064,1.006,0.9,1.762,1.909,1.762h3.804c1.008,0,1.842-0.767,1.908-1.772l0.727-11.276c0.338,0.438,0.849,0.731,1.425,0.731 c0.002,0,0.003,0,0.007,0c1.016,0,1.841-0.86,1.848-1.871l0.037-11.544C30.347,18.235,29.522,17.371,28.502,17.371z"></path>{' '}
                                      <circle
                                        cx="22.491"
                                        cy="11.022"
                                        r="5.115"
                                      ></circle>{' '}
                                      <path d="M11.14,9.006c-0.001,0-8.809-0.003-9.435-0.003c0,0-0.004,0-0.005,0c-0.801,0-1.455,0.665-1.453,1.467l0.031,9.085 c0.003,0.8,0.652,1.464,1.45,1.464c0.001,0,0.004,0,0.005,0c0.451,0,0.854-0.225,1.118-0.55l0.573,8.841 c0.051,0.789,0.707,1.383,1.5,1.383h2.989c0.791,0,1.446-0.602,1.499-1.391l0.57-8.859c0.266,0.343,0.667,0.575,1.12,0.575 c0.001,0,0.002,0,0.005,0c0.798,0,1.446-0.677,1.451-1.47l0.03-9.07C12.589,9.685,11.941,9.006,11.14,9.006z"></path>{' '}
                                      <circle
                                        cx="6.418"
                                        cy="4.018"
                                        r="4.018"
                                      ></circle>{' '}
                                    </g>{' '}
                                    <g>
                                      {' '}
                                      <path d="M33.839,9.006c0.001,0,8.809-0.003,9.436-0.003h0.004c0.802,0,1.455,0.665,1.453,1.467l-0.03,9.085 c-0.003,0.8-0.652,1.464-1.45,1.464c-0.001,0-0.004,0-0.005,0c-0.451,0-0.854-0.225-1.118-0.55l-0.572,8.841 c-0.052,0.789-0.707,1.383-1.5,1.383h-2.99c-0.791,0-1.445-0.602-1.498-1.391l-0.57-8.859c-0.266,0.343-0.667,0.575-1.12,0.575 c-0.001,0-0.002,0-0.005,0c-0.799,0-1.447-0.677-1.451-1.47l-0.029-9.07C32.39,9.685,33.038,9.006,33.839,9.006z"></path>{' '}
                                      <circle
                                        cx="38.562"
                                        cy="4.018"
                                        r="4.018"
                                      ></circle>{' '}
                                    </g>{' '}
                                  </g>{' '}
                                </g>
                              </svg>
                              Dish Categories
                            </NavLink>
                          </li>

                          <li>
                            <NavLink
                              to="/all-dishes"
                              className={({ isActive }) =>
                                `group relative flex items-center gap-2.5 rounded-sm py-2 px-4 font-medium ${
                                  isActive
                                    ? 'bg-yellow text-black dark:bg-meta-4 dark:text-white'
                                    : 'text-bodydark1 hover:bg-yellow hover:text-black dark:hover:bg-meta-4'
                                } duration-300 ease-in-out`
                              }
                            >
                              <svg
                                fill="none"
                                id="Capa_1"
                                className="fill-current"
                                width="18"
                                height="18"
                                xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 44.979 44.979"
                              >
                                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                                <g
                                  id="SVGRepo_tracerCarrier"
                                  stroke-linecap="round"
                                  stroke-linejoin="round"
                                ></g>
                                <g id="SVGRepo_iconCarrier">
                                  {' '}
                                  <g>
                                    {' '}
                                    <g>
                                      {' '}
                                      <path d="M28.502,17.371c-0.002,0-11.213-0.004-12.011-0.004c0,0-0.005,0-0.006,0c-1.021,0-1.853,0.846-1.85,1.867l0.04,11.565 c0.004,1.018,0.83,1.863,1.845,1.863c0.002,0,0.005,0,0.007,0c0.574,0,1.086-0.287,1.423-0.701l0.729,11.256 c0.064,1.006,0.9,1.762,1.909,1.762h3.804c1.008,0,1.842-0.767,1.908-1.772l0.727-11.276c0.338,0.438,0.849,0.731,1.425,0.731 c0.002,0,0.003,0,0.007,0c1.016,0,1.841-0.86,1.848-1.871l0.037-11.544C30.347,18.235,29.522,17.371,28.502,17.371z"></path>{' '}
                                      <circle
                                        cx="22.491"
                                        cy="11.022"
                                        r="5.115"
                                      ></circle>{' '}
                                      <path d="M11.14,9.006c-0.001,0-8.809-0.003-9.435-0.003c0,0-0.004,0-0.005,0c-0.801,0-1.455,0.665-1.453,1.467l0.031,9.085 c0.003,0.8,0.652,1.464,1.45,1.464c0.001,0,0.004,0,0.005,0c0.451,0,0.854-0.225,1.118-0.55l0.573,8.841 c0.051,0.789,0.707,1.383,1.5,1.383h2.989c0.791,0,1.446-0.602,1.499-1.391l0.57-8.859c0.266,0.343,0.667,0.575,1.12,0.575 c0.001,0,0.002,0,0.005,0c0.798,0,1.446-0.677,1.451-1.47l0.03-9.07C12.589,9.685,11.941,9.006,11.14,9.006z"></path>{' '}
                                      <circle
                                        cx="6.418"
                                        cy="4.018"
                                        r="4.018"
                                      ></circle>{' '}
                                    </g>{' '}
                                    <g>
                                      {' '}
                                      <path d="M33.839,9.006c0.001,0,8.809-0.003,9.436-0.003h0.004c0.802,0,1.455,0.665,1.453,1.467l-0.03,9.085 c-0.003,0.8-0.652,1.464-1.45,1.464c-0.001,0-0.004,0-0.005,0c-0.451,0-0.854-0.225-1.118-0.55l-0.572,8.841 c-0.052,0.789-0.707,1.383-1.5,1.383h-2.99c-0.791,0-1.445-0.602-1.498-1.391l-0.57-8.859c-0.266,0.343-0.667,0.575-1.12,0.575 c-0.001,0-0.002,0-0.005,0c-0.799,0-1.447-0.677-1.451-1.47l-0.029-9.07C32.39,9.685,33.038,9.006,33.839,9.006z"></path>{' '}
                                      <circle
                                        cx="38.562"
                                        cy="4.018"
                                        r="4.018"
                                      ></circle>{' '}
                                    </g>{' '}
                                  </g>{' '}
                                </g>
                              </svg>
                              Dishes
                            </NavLink>
                          </li>
                       
                          <li>
                            <NavLink
                              to="/all-custom-options"
                              className={({ isActive }) =>
                                `group relative flex items-center gap-2.5 rounded-sm py-2 px-4 font-medium ${
                                  isActive
                                    ? 'bg-yellow text-black dark:bg-meta-4 dark:text-white'
                                    : 'text-bodydark1 hover:bg-yellow hover:text-black dark:hover:bg-meta-4'
                                } duration-300 ease-in-out`
                              }
                            >
                              <svg
                                fill="none"
                                id="Capa_1"
                                className="fill-current"
                                width="18"
                                height="18"
                                xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 44.979 44.979"
                              >
                                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                                <g
                                  id="SVGRepo_tracerCarrier"
                                  stroke-linecap="round"
                                  stroke-linejoin="round"
                                ></g>
                                <g id="SVGRepo_iconCarrier">
                                  {' '}
                                  <g>
                                    {' '}
                                    <g>
                                      {' '}
                                      <path d="M28.502,17.371c-0.002,0-11.213-0.004-12.011-0.004c0,0-0.005,0-0.006,0c-1.021,0-1.853,0.846-1.85,1.867l0.04,11.565 c0.004,1.018,0.83,1.863,1.845,1.863c0.002,0,0.005,0,0.007,0c0.574,0,1.086-0.287,1.423-0.701l0.729,11.256 c0.064,1.006,0.9,1.762,1.909,1.762h3.804c1.008,0,1.842-0.767,1.908-1.772l0.727-11.276c0.338,0.438,0.849,0.731,1.425,0.731 c0.002,0,0.003,0,0.007,0c1.016,0,1.841-0.86,1.848-1.871l0.037-11.544C30.347,18.235,29.522,17.371,28.502,17.371z"></path>{' '}
                                      <circle
                                        cx="22.491"
                                        cy="11.022"
                                        r="5.115"
                                      ></circle>{' '}
                                      <path d="M11.14,9.006c-0.001,0-8.809-0.003-9.435-0.003c0,0-0.004,0-0.005,0c-0.801,0-1.455,0.665-1.453,1.467l0.031,9.085 c0.003,0.8,0.652,1.464,1.45,1.464c0.001,0,0.004,0,0.005,0c0.451,0,0.854-0.225,1.118-0.55l0.573,8.841 c0.051,0.789,0.707,1.383,1.5,1.383h2.989c0.791,0,1.446-0.602,1.499-1.391l0.57-8.859c0.266,0.343,0.667,0.575,1.12,0.575 c0.001,0,0.002,0,0.005,0c0.798,0,1.446-0.677,1.451-1.47l0.03-9.07C12.589,9.685,11.941,9.006,11.14,9.006z"></path>{' '}
                                      <circle
                                        cx="6.418"
                                        cy="4.018"
                                        r="4.018"
                                      ></circle>{' '}
                                    </g>{' '}
                                    <g>
                                      {' '}
                                      <path d="M33.839,9.006c0.001,0,8.809-0.003,9.436-0.003h0.004c0.802,0,1.455,0.665,1.453,1.467l-0.03,9.085 c-0.003,0.8-0.652,1.464-1.45,1.464c-0.001,0-0.004,0-0.005,0c-0.451,0-0.854-0.225-1.118-0.55l-0.572,8.841 c-0.052,0.789-0.707,1.383-1.5,1.383h-2.99c-0.791,0-1.445-0.602-1.498-1.391l-0.57-8.859c-0.266,0.343-0.667,0.575-1.12,0.575 c-0.001,0-0.002,0-0.005,0c-0.799,0-1.447-0.677-1.451-1.47l-0.029-9.07C32.39,9.685,33.038,9.006,33.839,9.006z"></path>{' '}
                                      <circle
                                        cx="38.562"
                                        cy="4.018"
                                        r="4.018"
                                      ></circle>{' '}
                                    </g>{' '}
                                  </g>{' '}
                                </g>
                              </svg>
                              Custom Options
                            </NavLink>
                          </li>
                       
                        </ul>
                      </div>
                      {/* <!-- Dropdown Menu End --> */}
                    </React.Fragment>
                  );
                }}
              </SidebarLinkGroup>
              {/* <!-- Menu Item Forms --> */}

              {/* <!-- Menu Item All Users --> */}
              <li>
                <NavLink
                  to="/all-users"
                  className={({ isActive }) =>
                    `group relative flex items-center gap-2.5 rounded-sm py-2 px-4 font-medium ${
                      isActive
                        ? 'bg-yellow text-black dark:bg-meta-4 dark:text-white'
                        : 'text-bodydark1 hover:bg-yellow hover:text-black dark:hover:bg-meta-4'
                    } duration-300 ease-in-out`
                  }
                >
                  <svg
                    fill="none"
                    id="Capa_1"
                    className="fill-current"
                    width="18"
                    height="18"
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 0 44.979 44.979"
                  >
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g
                      id="SVGRepo_tracerCarrier"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                    ></g>
                    <g id="SVGRepo_iconCarrier">
                      {' '}
                      <g>
                        {' '}
                        <g>
                          {' '}
                          <path d="M28.502,17.371c-0.002,0-11.213-0.004-12.011-0.004c0,0-0.005,0-0.006,0c-1.021,0-1.853,0.846-1.85,1.867l0.04,11.565 c0.004,1.018,0.83,1.863,1.845,1.863c0.002,0,0.005,0,0.007,0c0.574,0,1.086-0.287,1.423-0.701l0.729,11.256 c0.064,1.006,0.9,1.762,1.909,1.762h3.804c1.008,0,1.842-0.767,1.908-1.772l0.727-11.276c0.338,0.438,0.849,0.731,1.425,0.731 c0.002,0,0.003,0,0.007,0c1.016,0,1.841-0.86,1.848-1.871l0.037-11.544C30.347,18.235,29.522,17.371,28.502,17.371z"></path>{' '}
                          <circle cx="22.491" cy="11.022" r="5.115"></circle>{' '}
                          <path d="M11.14,9.006c-0.001,0-8.809-0.003-9.435-0.003c0,0-0.004,0-0.005,0c-0.801,0-1.455,0.665-1.453,1.467l0.031,9.085 c0.003,0.8,0.652,1.464,1.45,1.464c0.001,0,0.004,0,0.005,0c0.451,0,0.854-0.225,1.118-0.55l0.573,8.841 c0.051,0.789,0.707,1.383,1.5,1.383h2.989c0.791,0,1.446-0.602,1.499-1.391l0.57-8.859c0.266,0.343,0.667,0.575,1.12,0.575 c0.001,0,0.002,0,0.005,0c0.798,0,1.446-0.677,1.451-1.47l0.03-9.07C12.589,9.685,11.941,9.006,11.14,9.006z"></path>{' '}
                          <circle cx="6.418" cy="4.018" r="4.018"></circle>{' '}
                        </g>{' '}
                        <g>
                          {' '}
                          <path d="M33.839,9.006c0.001,0,8.809-0.003,9.436-0.003h0.004c0.802,0,1.455,0.665,1.453,1.467l-0.03,9.085 c-0.003,0.8-0.652,1.464-1.45,1.464c-0.001,0-0.004,0-0.005,0c-0.451,0-0.854-0.225-1.118-0.55l-0.572,8.841 c-0.052,0.789-0.707,1.383-1.5,1.383h-2.99c-0.791,0-1.445-0.602-1.498-1.391l-0.57-8.859c-0.266,0.343-0.667,0.575-1.12,0.575 c-0.001,0-0.002,0-0.005,0c-0.799,0-1.447-0.677-1.451-1.47l-0.029-9.07C32.39,9.685,33.038,9.006,33.839,9.006z"></path>{' '}
                          <circle cx="38.562" cy="4.018" r="4.018"></circle>{' '}
                        </g>{' '}
                      </g>{' '}
                    </g>
                  </svg>
                  All Users
                </NavLink>
              </li>
              {/* <!-- Menu Item Users --> */}

              <br></br>

              {/* <!-- Menu Item Settings --> */}
              <li>
                <NavLink
                  to="/settings"
                  className={({ isActive }) =>
                    `group relative flex items-center gap-2.5 rounded-sm py-2 px-4 font-medium ${
                      isActive
                        ? 'bg-yellow text-black dark:bg-meta-4 dark:text-white'
                        : 'text-bodydark1 hover:bg-yellow hover:text-black dark:hover:bg-meta-4'
                    } duration-300 ease-in-out`
                  }
                >
                  <svg
                    className="fill-current"
                    width="18"
                    height="18"
                    viewBox="0 0 18 18"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M15.7499 2.9812H14.2874V2.36245C14.2874 2.02495 14.0062 1.71558 13.6405 1.71558C13.2749 1.71558 12.9937 1.99683 12.9937 2.36245V2.9812H4.97803V2.36245C4.97803 2.02495 4.69678 1.71558 4.33115 1.71558C3.96553 1.71558 3.68428 1.99683 3.68428 2.36245V2.9812H2.2499C1.29365 2.9812 0.478027 3.7687 0.478027 4.75308V14.5406C0.478027 15.4968 1.26553 16.3125 2.2499 16.3125H15.7499C16.7062 16.3125 17.5218 15.525 17.5218 14.5406V4.72495C17.5218 3.7687 16.7062 2.9812 15.7499 2.9812ZM1.77178 8.21245H4.1624V10.9968H1.77178V8.21245ZM5.42803 8.21245H8.38115V10.9968H5.42803V8.21245ZM8.38115 12.2625V15.0187H5.42803V12.2625H8.38115ZM9.64678 12.2625H12.5999V15.0187H9.64678V12.2625ZM9.64678 10.9968V8.21245H12.5999V10.9968H9.64678ZM13.8374 8.21245H16.228V10.9968H13.8374V8.21245ZM2.2499 4.24683H3.7124V4.83745C3.7124 5.17495 3.99365 5.48433 4.35928 5.48433C4.7249 5.48433 5.00615 5.20308 5.00615 4.83745V4.24683H13.0499V4.83745C13.0499 5.17495 13.3312 5.48433 13.6968 5.48433C14.0624 5.48433 14.3437 5.20308 14.3437 4.83745V4.24683H15.7499C16.0312 4.24683 16.2562 4.47183 16.2562 4.75308V6.94683H1.77178V4.75308C1.77178 4.47183 1.96865 4.24683 2.2499 4.24683ZM1.77178 14.5125V12.2343H4.1624V14.9906H2.2499C1.96865 15.0187 1.77178 14.7937 1.77178 14.5125ZM15.7499 15.0187H13.8374V12.2625H16.228V14.5406C16.2562 14.7937 16.0312 15.0187 15.7499 15.0187Z"
                      fill=""
                    />
                  </svg>
                  Settings
                </NavLink>
              </li>
              {/* <!-- Menu Item Dues --> */}

              <br></br>
              <br></br>
              <br></br>

              {/* <!-- Menu Item Logout --> */}
              <li>
                <NavLink
                  to="/signin"
                  className={({ isActive }) =>
                    `group relative flex items-center gap-2.5 rounded-sm py-2 px-4 font-medium ${
                      isActive
                        ? 'bg-yellow text-black dark:bg-meta-4 dark:text-white'
                        : 'text-bodydark1 hover:bg-yellow hover:text-black dark:hover:bg-meta-4'
                    } duration-300 ease-in-out`
                  }
                >
                  <svg
                    className="fill-current"
                    width="18"
                    height="18"
                    viewBox="0 0 18 18"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M15.7499 2.9812H14.2874V2.36245C14.2874 2.02495 14.0062 1.71558 13.6405 1.71558C13.2749 1.71558 12.9937 1.99683 12.9937 2.36245V2.9812H4.97803V2.36245C4.97803 2.02495 4.69678 1.71558 4.33115 1.71558C3.96553 1.71558 3.68428 1.99683 3.68428 2.36245V2.9812H2.2499C1.29365 2.9812 0.478027 3.7687 0.478027 4.75308V14.5406C0.478027 15.4968 1.26553 16.3125 2.2499 16.3125H15.7499C16.7062 16.3125 17.5218 15.525 17.5218 14.5406V4.72495C17.5218 3.7687 16.7062 2.9812 15.7499 2.9812ZM1.77178 8.21245H4.1624V10.9968H1.77178V8.21245ZM5.42803 8.21245H8.38115V10.9968H5.42803V8.21245ZM8.38115 12.2625V15.0187H5.42803V12.2625H8.38115ZM9.64678 12.2625H12.5999V15.0187H9.64678V12.2625ZM9.64678 10.9968V8.21245H12.5999V10.9968H9.64678ZM13.8374 8.21245H16.228V10.9968H13.8374V8.21245ZM2.2499 4.24683H3.7124V4.83745C3.7124 5.17495 3.99365 5.48433 4.35928 5.48433C4.7249 5.48433 5.00615 5.20308 5.00615 4.83745V4.24683H13.0499V4.83745C13.0499 5.17495 13.3312 5.48433 13.6968 5.48433C14.0624 5.48433 14.3437 5.20308 14.3437 4.83745V4.24683H15.7499C16.0312 4.24683 16.2562 4.47183 16.2562 4.75308V6.94683H1.77178V4.75308C1.77178 4.47183 1.96865 4.24683 2.2499 4.24683ZM1.77178 14.5125V12.2343H4.1624V14.9906H2.2499C1.96865 15.0187 1.77178 14.7937 1.77178 14.5125ZM15.7499 15.0187H13.8374V12.2625H16.228V14.5406C16.2562 14.7937 16.0312 15.0187 15.7499 15.0187Z"
                      fill=""
                    />
                  </svg>
                  Logout
                </NavLink>
              </li>
              {/* <!-- Menu Item Dues --> */}
            </ul>
          </div>
        </nav>
        {/* <!-- Sidebar Menu --> */}
      </div>
    </aside>
  );
};

export default Sidebar;
