import React, { useMemo, useState } from 'react';

type DocumentRecord = {
  id: string;
  name: string;
  url: string;
  type: 'pdf' | 'image';
  verified: boolean;
};

type ApplicationStatus = 'pending' | 'approved' | 'flagged';

type ApplicationRecord = {
  id: string;
  fullName: string;
  email: string;
  phoneNumber: string;
  cuisineSpecialty: string;
  location: string;
  submittedAt: string;
  experienceYears: number;
  averageOrderValue: number;
  status: ApplicationStatus;
  commissionTier: string | null;
  documents: DocumentRecord[];
  notes: string[];
};

type AuditLogEntry = {
  id: string;
  actor: string;
  action: string;
  target: string;
  timestamp: string;
  notes?: string;
};

const COMMISSION_TIERS = [
  { id: 'standard', label: 'Standard (20%)', description: 'Default platform commission for new cooks.' },
  { id: 'preferred', label: 'Preferred (15%)', description: 'For highly rated cooks with consistent volumes.' },
  { id: 'premium', label: 'Premium (25%)', description: 'Applies to white-glove service tiers and concierge menus.' },
];

const INITIAL_APPLICATIONS: ApplicationRecord[] = [
  {
    id: 'APP-2418',
    fullName: 'Bianca Adebayo',
    email: 'bianca.adebayo@example.com',
    phoneNumber: '+1 (470) 555-9022',
    cuisineSpecialty: 'Nigerian fusion',
    location: 'Atlanta, GA',
    submittedAt: '2024-05-03T15:00:00Z',
    experienceYears: 8,
    averageOrderValue: 185,
    status: 'pending',
    commissionTier: null,
    documents: [
      {
        id: 'DOC-1',
        name: 'ServSafe Manager Certificate',
        url: 'https://example.com/documents/servsafe-bianca.pdf',
        type: 'pdf',
        verified: true,
      },
      {
        id: 'DOC-2',
        name: 'Georgia Food Handler Permit',
        url: 'https://example.com/documents/ga-permit-bianca.pdf',
        type: 'pdf',
        verified: true,
      },
      {
        id: 'DOC-3',
        name: 'Sample Menu & Pricing Sheet',
        url: 'https://example.com/documents/menu-bianca.pdf',
        type: 'pdf',
        verified: false,
      },
    ],
    notes: [
      'Specializes in plantain-forward tasting menus with modern plating.',
      'Referred by client Samuel Obeng (repeat customer).',
    ],
  },
  {
    id: 'APP-2422',
    fullName: 'Mateo Alvarez',
    email: 'mateo.alvarez@example.com',
    phoneNumber: '+1 (415) 555-7712',
    cuisineSpecialty: 'Coastal Peruvian',
    location: 'San Francisco, CA',
    submittedAt: '2024-05-07T19:30:00Z',
    experienceYears: 5,
    averageOrderValue: 210,
    status: 'pending',
    commissionTier: null,
    documents: [
      {
        id: 'DOC-4',
        name: 'California Cottage Food License',
        url: 'https://example.com/documents/cottage-food-mateo.pdf',
        type: 'pdf',
        verified: true,
      },
      {
        id: 'DOC-5',
        name: 'Food Safety Inspection - 2024',
        url: 'https://example.com/documents/inspection-mateo.pdf',
        type: 'pdf',
        verified: false,
      },
    ],
    notes: ['Has pop-up collaboration with La Mar; strong Instagram presence.'],
  },
  {
    id: 'APP-2388',
    fullName: 'Priya Desai',
    email: 'priya.desai@example.com',
    phoneNumber: '+1 (312) 555-8844',
    cuisineSpecialty: 'Gujarati family-style',
    location: 'Chicago, IL',
    submittedAt: '2024-04-22T12:45:00Z',
    experienceYears: 11,
    averageOrderValue: 160,
    status: 'flagged',
    commissionTier: 'standard',
    documents: [
      {
        id: 'DOC-6',
        name: 'City of Chicago Business License',
        url: 'https://example.com/documents/business-license-priya.pdf',
        type: 'pdf',
        verified: true,
      },
      {
        id: 'DOC-7',
        name: 'Kitchen Inspection Follow-up',
        url: 'https://example.com/documents/inspection-priya.pdf',
        type: 'pdf',
        verified: false,
      },
    ],
    notes: ['Awaiting updated kitchen inspection photos before approval.'],
  },
];

const VerificationDashboard: React.FC = () => {
  const [applications, setApplications] = useState<ApplicationRecord[]>(INITIAL_APPLICATIONS);
  const [selectedId, setSelectedId] = useState<string | null>(
    INITIAL_APPLICATIONS.find((application) => application.status === 'pending')?.id || null,
  );
  const [auditLog, setAuditLog] = useState<AuditLogEntry[]>([
    {
      id: 'LOG-1001',
      actor: 'Jordan (Admin)',
      action: 'Flagged application',
      target: 'APP-2388',
      timestamp: '2024-04-24T16:10:00Z',
      notes: 'Requested updated kitchen inspection after expiring permit.',
    },
  ]);
  const [commissionSelection, setCommissionSelection] = useState<string>('standard');
  const [adminNotes, setAdminNotes] = useState<string>('');
  const [statusFilter, setStatusFilter] = useState<ApplicationStatus | 'all'>('pending');
  const [searchTerm, setSearchTerm] = useState<string>('');

  const selectedApplication = useMemo(() => {
    if (!selectedId) {
      return undefined;
    }
    return applications.find((application) => application.id === selectedId);
  }, [applications, selectedId]);

  const filteredApplications = useMemo(() => {
    const normalizedSearch = searchTerm.trim().toLowerCase();

    return applications
      .filter((application) => {
        if (statusFilter !== 'all') {
          return application.status === statusFilter;
        }
        return true;
      })
      .filter((application) => {
        if (!normalizedSearch) {
          return true;
        }

        return (
          application.fullName.toLowerCase().includes(normalizedSearch) ||
          application.cuisineSpecialty.toLowerCase().includes(normalizedSearch) ||
          application.location.toLowerCase().includes(normalizedSearch) ||
          application.id.toLowerCase().includes(normalizedSearch)
        );
      })
      .sort((a, b) => new Date(b.submittedAt).getTime() - new Date(a.submittedAt).getTime());
  }, [applications, searchTerm, statusFilter]);

  const handleSelectApplication = (applicationId: string) => {
    setSelectedId(applicationId);
    setAdminNotes('');
    setCommissionSelection('standard');
  };

  const appendAuditLog = (entry: Omit<AuditLogEntry, 'id' | 'timestamp'> & { timestamp?: string }) => {
    const timestamp = entry.timestamp ?? new Date().toISOString();
    setAuditLog((prev) => [
      {
        id: `LOG-${(prev.length + 1001).toString().padStart(4, '0')}`,
        timestamp,
        ...entry,
      },
      ...prev,
    ]);
  };

  const handleDecision = (status: Extract<ApplicationStatus, 'approved' | 'flagged'>) => {
    if (!selectedApplication) {
      return;
    }

    setApplications((prev) =>
      prev.map((application) => {
        if (application.id !== selectedApplication.id) {
          return application;
        }

        const updatedNotes = adminNotes.trim()
          ? [...application.notes, adminNotes.trim()]
          : application.notes;

        return {
          ...application,
          status,
          commissionTier: status === 'approved' ? commissionSelection : application.commissionTier,
          notes: updatedNotes,
        };
      }),
    );

    appendAuditLog({
      actor: 'You',
      action: status === 'approved' ? 'Approved application' : 'Flagged application',
      target: selectedApplication.id,
      notes:
        status === 'approved'
          ? `Commission tier: ${commissionSelection}${adminNotes ? ` | Notes: ${adminNotes}` : ''}`
          : adminNotes || 'No additional notes provided.',
    });

    if (status === 'approved') {
      setStatusFilter('pending');
    }
    setAdminNotes('');
  };

  const pendingCount = useMemo(
    () => applications.filter((application) => application.status === 'pending').length,
    [applications],
  );

  const flaggedCount = useMemo(
    () => applications.filter((application) => application.status === 'flagged').length,
    [applications],
  );

  const approvedCount = useMemo(
    () => applications.filter((application) => application.status === 'approved').length,
    [applications],
  );

  return (
    <div className="space-y-6">
      <header className="flex flex-col gap-4 rounded-md border border-stroke bg-white p-6 shadow-sm dark:border-strokedark dark:bg-boxdark">
        <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-black dark:text-white">Cook Verification Queue</h1>
            <p className="text-sm text-body dark:text-bodydark">
              Review pending cook applications, approve qualified chefs, and maintain a complete audit trail of admin actions.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-2 text-sm">
            <span className="rounded-full bg-warning/10 px-3 py-1 text-warning">Pending: {pendingCount}</span>
            <span className="rounded-full bg-success/10 px-3 py-1 text-success">Approved: {approvedCount}</span>
            <span className="rounded-full bg-danger/10 px-3 py-1 text-danger">Flagged: {flaggedCount}</span>
          </div>
        </div>
        <div className="flex flex-col gap-3 md:flex-row md:items-center">
          <div className="relative flex-1">
            <input
              type="text"
              value={searchTerm}
              onChange={(event) => setSearchTerm(event.target.value)}
              placeholder="Search by chef, cuisine, city, or application ID"
              className="w-full rounded border border-stroke bg-transparent py-3 pl-11 pr-4 text-sm outline-none transition focus:border-primary focus:ring-0 dark:border-strokedark dark:bg-boxdark"
            />
            <span className="pointer-events-none absolute inset-y-0 left-3 flex items-center text-bodydark">
              <svg
                className="h-4 w-4"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.5"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="m21 21-4.35-4.35m0 0a7.5 7.5 0 1 0-10.607 0 7.5 7.5 0 0 0 10.607 0Z"
                />
              </svg>
            </span>
          </div>
          <div className="flex gap-2">
            {(['all', 'pending', 'approved', 'flagged'] as const).map((option) => (
              <button
                key={option}
                onClick={() => setStatusFilter(option)}
                className={`rounded-full px-4 py-2 text-sm capitalize transition ${
                  statusFilter === option
                    ? 'bg-primary text-white'
                    : 'border border-stroke text-body hover:bg-primary/10 dark:border-strokedark dark:text-bodydark'
                }`}
                type="button"
              >
                {option}
              </button>
            ))}
          </div>
        </div>
      </header>

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-[1.1fr_minmax(0,1fr)]">
        <section className="rounded-md border border-stroke bg-white shadow-sm dark:border-strokedark dark:bg-boxdark">
          <div className="border-b border-stroke px-6 py-4 dark:border-strokedark">
            <h2 className="text-lg font-semibold text-black dark:text-white">Application Queue</h2>
            <p className="text-xs text-body dark:text-bodydark">Newest submissions appear first. Select an application to review documents and take action.</p>
          </div>
          <div className="max-h-[520px] divide-y divide-stroke overflow-y-auto dark:divide-strokedark">
            {filteredApplications.length === 0 ? (
              <div className="flex flex-col items-center justify-center gap-2 px-6 py-12 text-center text-sm text-body dark:text-bodydark">
                <svg
                  className="h-12 w-12 text-bodydark"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M3 4h13M3 8h13m-5 12h8m-3-4h3M5 12h6m-6 4h6M4 6V4m0 4V6m0 2v2m0 4v2m16-6V4a1 1 0 0 0-1-1h-3"
                  />
                </svg>
                <div>
                  <p className="font-medium text-black dark:text-white">No applications match the current filters.</p>
                  <p>Adjust the status filter or search keywords to continue reviewing submissions.</p>
                </div>
              </div>
            ) : (
              filteredApplications.map((application) => {
                const isSelected = selectedApplication?.id === application.id;
                const outstandingDocs = application.documents.filter((document) => !document.verified).length;

                return (
                  <button
                    key={application.id}
                    type="button"
                    onClick={() => handleSelectApplication(application.id)}
                    className={`flex w-full flex-col gap-3 px-6 py-4 text-left transition hover:bg-primary/5 focus:outline-none ${
                      isSelected ? 'border-l-4 border-primary bg-primary/10 dark:bg-primary/20' : ''
                    }`}
                  >
                    <div className="flex items-start justify-between gap-4">
                      <div>
                        <h3 className="text-sm font-semibold text-black dark:text-white">{application.fullName}</h3>
                        <p className="text-xs uppercase tracking-wide text-body dark:text-bodydark">
                          {application.cuisineSpecialty}
                        </p>
                      </div>
                      <span
                        className={`rounded-full px-3 py-1 text-xs font-medium capitalize ${
                          application.status === 'approved'
                            ? 'bg-success/10 text-success'
                            : application.status === 'flagged'
                            ? 'bg-danger/10 text-danger'
                            : 'bg-warning/10 text-warning'
                        }`}
                      >
                        {application.status}
                      </span>
                    </div>
                    <div className="flex flex-wrap items-center gap-3 text-xs text-body dark:text-bodydark">
                      <span className="flex items-center gap-1">
                        <svg className="h-3.5 w-3.5" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24">
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            d="M12 21a9 9 0 1 0-9-9"
                          />
                          <path d="M12 7v5l3 3" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                        Submitted {new Date(application.submittedAt).toLocaleDateString()}
                      </span>
                      <span className="flex items-center gap-1">
                        <svg className="h-3.5 w-3.5" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24">
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            d="M17.657 16.657 13.414 12l4.243-4.243M6.343 7.343 10.586 12l-4.243 4.243"
                          />
                        </svg>
                        {application.location}
                      </span>
                      <span className="flex items-center gap-1">
                        <svg className="h-3.5 w-3.5" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24">
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            d="M12 14.25A2.25 2.25 0 1 0 12 9.75a2.25 2.25 0 0 0 0 4.5Z"
                          />
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            d="M12 6v.75m0 10.5v.75m6-6h-.75M6.75 12H6m10.606-5.303-.53.53M7.924 16.076l-.53.53m12.126-6.228-.53-.53M7.924 7.924l-.53-.53"
                          />
                        </svg>
                        Avg order ${application.averageOrderValue}
                      </span>
                      {outstandingDocs > 0 && (
                        <span className="flex items-center gap-1 text-danger">
                          <svg className="h-3.5 w-3.5" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24">
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              d="M12 9v4m0 4h.01M2.25 12a9.75 9.75 0 1 1 19.5 0 9.75 9.75 0 0 1-19.5 0Z"
                            />
                          </svg>
                          {outstandingDocs} outstanding document{outstandingDocs > 1 ? 's' : ''}
                        </span>
                      )}
                    </div>
                  </button>
                );
              })
            )}
          </div>
        </section>

        <section className="space-y-6">
          <div className="rounded-md border border-stroke bg-white shadow-sm dark:border-strokedark dark:bg-boxdark">
            <div className="border-b border-stroke px-6 py-4 dark:border-strokedark">
              <h2 className="text-lg font-semibold text-black dark:text-white">Application Detail</h2>
              <p className="text-xs text-body dark:text-bodydark">Confirm identity, verify documentation, and assign the right commission tier for approved cooks.</p>
            </div>

            {selectedApplication ? (
              <div className="space-y-6 px-6 py-5">
                <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                  <div>
                    <p className="text-xs uppercase tracking-wide text-bodydark">Chef</p>
                    <p className="text-base font-semibold text-black dark:text-white">{selectedApplication.fullName}</p>
                    <p className="text-sm text-body dark:text-bodydark">{selectedApplication.email}</p>
                    <p className="text-sm text-body dark:text-bodydark">{selectedApplication.phoneNumber}</p>
                  </div>
                  <div className="flex flex-col gap-1">
                    <p className="text-xs uppercase tracking-wide text-bodydark">Profile Snapshot</p>
                    <div className="flex flex-wrap gap-2 text-sm text-body dark:text-bodydark">
                      <span className="rounded border border-stroke px-2 py-1 dark:border-strokedark">
                        {selectedApplication.cuisineSpecialty}
                      </span>
                      <span className="rounded border border-stroke px-2 py-1 dark:border-strokedark">
                        {selectedApplication.location}
                      </span>
                      <span className="rounded border border-stroke px-2 py-1 dark:border-strokedark">
                        {selectedApplication.experienceYears} yrs experience
                      </span>
                      <span className="rounded border border-stroke px-2 py-1 dark:border-strokedark">
                        Avg order ${selectedApplication.averageOrderValue}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <h3 className="text-sm font-semibold text-black dark:text-white">Compliance Documents</h3>
                    <span className="text-xs text-body dark:text-bodydark">
                      {selectedApplication.documents.filter((document) => document.verified).length} of{' '}
                      {selectedApplication.documents.length} verified
                    </span>
                  </div>
                  <ul className="space-y-3">
                    {selectedApplication.documents.map((document) => (
                      <li
                        key={document.id}
                        className="flex items-center justify-between gap-3 rounded border border-dashed border-stroke px-3 py-2 text-sm dark:border-strokedark"
                      >
                        <div className="flex flex-col">
                          <span className="font-medium text-black dark:text-white">{document.name}</span>
                          <span className="text-xs text-bodydark">{document.type.toUpperCase()} file</span>
                        </div>
                        <div className="flex items-center gap-3">
                          <span
                            className={`rounded-full px-3 py-1 text-xs font-medium ${
                              document.verified ? 'bg-success/10 text-success' : 'bg-warning/10 text-warning'
                            }`}
                          >
                            {document.verified ? 'Verified' : 'Pending review'}
                          </span>
                          <a
                            href={document.url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-xs font-medium text-primary hover:underline"
                          >
                            Open
                          </a>
                        </div>
                      </li>
                    ))}
                  </ul>
                </div>

                <div className="space-y-3">
                  <h3 className="text-sm font-semibold text-black dark:text-white">Existing Notes</h3>
                  <ul className="space-y-2 text-sm text-body dark:text-bodydark">
                    {selectedApplication.notes.map((note, index) => (
                      <li key={index} className="rounded border border-stroke bg-whiter/60 px-3 py-2 dark:border-strokedark dark:bg-meta-4/20">
                        {note}
                      </li>
                    ))}
                  </ul>
                </div>

                <div className="space-y-4 rounded-md border border-stroke bg-whiter/40 p-4 dark:border-strokedark dark:bg-meta-4/20">
                  <div>
                    <label className="text-xs font-semibold uppercase text-bodydark">Commission tier</label>
                    <div className="mt-3 grid grid-cols-1 gap-3 md:grid-cols-3">
                      {COMMISSION_TIERS.map((tier) => (
                        <label
                          key={tier.id}
                          className={`cursor-pointer rounded border p-3 text-sm transition dark:border-strokedark ${
                            commissionSelection === tier.id
                              ? 'border-primary bg-primary/10 text-primary'
                              : 'border-stroke text-body dark:text-bodydark'
                          }`}
                        >
                          <div className="flex items-center gap-2">
                            <input
                              type="radio"
                              name="commissionTier"
                              value={tier.id}
                              checked={commissionSelection === tier.id}
                              onChange={(event) => setCommissionSelection(event.target.value)}
                              className="text-primary"
                            />
                            <span className="font-semibold">{tier.label}</span>
                          </div>
                          <p className="mt-1 text-xs text-body dark:text-bodydark">{tier.description}</p>
                        </label>
                      ))}
                    </div>
                  </div>

                  <div>
                    <label htmlFor="admin-notes" className="text-xs font-semibold uppercase text-bodydark">
                      Internal notes (optional)
                    </label>
                    <textarea
                      id="admin-notes"
                      value={adminNotes}
                      onChange={(event) => setAdminNotes(event.target.value)}
                      rows={3}
                      placeholder="Record context for your decision — these notes appear in the audit log."
                      className="mt-2 w-full rounded border border-stroke bg-transparent p-3 text-sm outline-none transition focus:border-primary dark:border-strokedark dark:bg-boxdark"
                    />
                  </div>

                  <div className="flex flex-wrap gap-3">
                    <button
                      type="button"
                      onClick={() => handleDecision('approved')}
                      className="inline-flex items-center gap-2 rounded bg-success px-5 py-2 text-sm font-semibold text-white shadow hover:bg-success/90"
                    >
                      <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="m4.5 12 6 6 9-13.5" />
                      </svg>
                      Approve & assign tier
                    </button>
                    <button
                      type="button"
                      onClick={() => handleDecision('flagged')}
                      className="inline-flex items-center gap-2 rounded border border-danger px-5 py-2 text-sm font-semibold text-danger transition hover:bg-danger/10"
                    >
                      <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24">
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          d="M12 9v3.75m0 3.75h.008v.008H12zm-9.53.008a9.75 9.75 0 1 0 19.5 0 9.75 9.75 0 0 0-19.5 0Z"
                        />
                      </svg>
                      Flag for follow-up
                    </button>
                  </div>
                </div>
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center gap-4 px-6 py-16 text-center text-sm text-body dark:text-bodydark">
                <svg
                  className="h-12 w-12 text-bodydark"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h3a2.25 2.25 0 0 1 2.25 2.25V9m4.5 0h.75A2.25 2.25 0 0 1 21 11.25v8.25A2.25 2.25 0 0 1 18.75 21H5.25A2.25 2.25 0 0 1 3 19.5v-8.25A2.25 2.25 0 0 1 5.25 9H6m12 0H6m12 0v-.375A1.125 1.125 0 0 0 16.875 7.5h-9.75A1.125 1.125 0 0 0 6 8.625V9"
                  />
                </svg>
                <div>
                  <p className="font-medium text-black dark:text-white">Select an application to get started</p>
                  <p>Choose a chef from the queue to review documents, assign a commission tier, and log your decision.</p>
                </div>
              </div>
            )}
          </div>

          <div className="rounded-md border border-stroke bg-white shadow-sm dark:border-strokedark dark:bg-boxdark">
            <div className="border-b border-stroke px-6 py-4 dark:border-strokedark">
              <h2 className="text-lg font-semibold text-black dark:text-white">Admin Audit Log</h2>
              <p className="text-xs text-body dark:text-bodydark">Every decision taken on this page is recorded for compliance and hand-offs.</p>
            </div>
            <div className="max-h-72 divide-y divide-stroke overflow-y-auto text-sm dark:divide-strokedark">
              {auditLog.length === 0 ? (
                <div className="px-6 py-10 text-center text-body dark:text-bodydark">
                  Actions taken here will appear in the audit log for visibility across the ops team.
                </div>
              ) : (
                auditLog.map((entry) => (
                  <div key={entry.id} className="flex flex-col gap-1 px-6 py-4">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <p className="font-semibold text-black dark:text-white">{entry.actor}</p>
                      <span className="text-xs text-bodydark">{new Date(entry.timestamp).toLocaleString()}</span>
                    </div>
                    <p className="text-sm text-body dark:text-bodydark">
                      {entry.action} <span className="font-medium text-primary">{entry.target}</span>
                    </p>
                    {entry.notes && <p className="text-xs text-bodydark">{entry.notes}</p>}
                  </div>
                ))
              )}
            </div>
          </div>
        </section>
      </div>
    </div>
  );
};

export default VerificationDashboard;

