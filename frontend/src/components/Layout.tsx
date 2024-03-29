import { useLocation, useNavigate } from 'react-router-dom';
import { useAtom } from 'jotai';

import { fromToAtom } from '../utils/atoms';
import ArrowIcon from '../icons/ArrowIcon';

const Layout = ({ children }: { children: JSX.Element }) => {
  const { pathname } = useLocation();
  const navigate = useNavigate();
  const [fromTo] = useAtom(fromToAtom);

  return (
    <>
      {pathname !== '/' && fromTo.from.address ? (
        <>
          <header className="w-full bg-pm-accent p-6">
            <div className="mx-auto max-w-screen-sm">
              <button
                onClick={() => navigate(-1)}
                className="absolute top-7 focus:outline-none focus-visible:ring-2 focus-visible:ring-pm-white focus-visible:ring-offset-8 focus-visible:ring-offset-pm-accent"
                aria-label="Gå tillbaka"
              >
                <ArrowIcon className="fill-pm-white" />
              </button>
              <div className="flex flex-col justify-center">
                <div className="flex justify-center">
                  {fromTo && (
                    <p className="ml-4 text-center font-bold text-white">
                      {fromTo.from.address + '–' + fromTo.to.address}
                    </p>
                  )}
                </div>
                <p
                  className="text-center text-xs text-white"
                  aria-hidden="true"
                >
                  {pathname === '/departure-details'
                    ? 'Vald avgång'
                    : 'Tidigaste avgångar'}
                </p>
              </div>
            </div>
          </header>
          <main
            className={`${
              pathname === '/departure-details' && 'h-full'
            }  w-full bg-pm-background`}
          >
            {children}
          </main>
        </>
      ) : (
        <main className="h-full w-full bg-pm-accent">{children}</main>
      )}
    </>
  );
};

export default Layout;
