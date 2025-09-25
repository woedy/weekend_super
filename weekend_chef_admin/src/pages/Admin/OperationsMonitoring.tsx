import { useEffect, useMemo, useState } from 'react';
import CardDataStats from '../../components/CardDataStats';

interface OrderActivity {
  id: string;
  orderId: string;
  message: string;
  timestamp: string;
  type: 'order-update' | 'refund' | 'payout' | 'dispute' | 'export';
}

interface ActiveOrder {
  id: string;
  client: string;
  cook: string;
  stage: 'Pending' | 'Accepted' | 'Cooking' | 'Ready for Dispatch' | 'Dispatched';
  deliveryWindow: string;
  region: string;
  etaMinutes: number;
  groceryAdvance: number;
  gmv: number;
  onTime: boolean;
  repeatClient: boolean;
  promoCode?: string;
  dietaryFlags?: string[];
}

interface PendingPayout {
  id: string;
  orderId: string;
  cook: string;
  amount: number;
  scheduledFor: string;
  status: 'Pending' | 'Ready' | 'On Hold' | 'Released';
}

interface DisputeTicket {
  id: string;
  orderId: string;
  openedAt: string;
  reportedBy: string;
  summary: string;
  amountAtRisk: number;
  slaHoursRemaining: number;
  status: 'Investigating' | 'Waiting on Client' | 'Waiting on Cook' | 'Resolved';
}

interface ExportPreset {
  id: string;
  label: string;
  description: string;
  metrics: Array<{ name: string; value: string | number; trend: string }>;
}

const formatCurrency = (value: number) =>
  new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    maximumFractionDigits: value % 1 === 0 ? 0 : 2,
  }).format(value);

const OperationsMonitoring = () => {
  const [timeRange, setTimeRange] = useState<'today' | '7d' | '30d'>('today');
  const [regionFilter, setRegionFilter] = useState<'all' | 'Brooklyn' | 'Manhattan' | 'Queens'>('all');
  const [statusFilter, setStatusFilter] = useState<'all' | ActiveOrder['stage']>('all');
  const [orders, setOrders] = useState<ActiveOrder[]>([
    {
      id: 'ORD-3421',
      client: 'Jasmine Lee',
      cook: 'Chef Marco',
      stage: 'Cooking',
      deliveryWindow: 'Today • 6:00 PM – 7:00 PM',
      region: 'Brooklyn',
      etaMinutes: 35,
      groceryAdvance: 62,
      gmv: 185.5,
      onTime: true,
      repeatClient: true,
      dietaryFlags: ['Gluten Free'],
    },
    {
      id: 'ORD-3416',
      client: 'Evan Chen',
      cook: 'Chef Amina',
      stage: 'Accepted',
      deliveryWindow: 'Today • 7:30 PM – 8:15 PM',
      region: 'Manhattan',
      etaMinutes: 85,
      groceryAdvance: 48,
      gmv: 142.75,
      onTime: true,
      repeatClient: false,
      dietaryFlags: ['Nut Allergy'],
    },
    {
      id: 'ORD-3409',
      client: 'Priya Patel',
      cook: 'Chef Malik',
      stage: 'Ready for Dispatch',
      deliveryWindow: 'Today • 5:30 PM – 6:15 PM',
      region: 'Queens',
      etaMinutes: 12,
      groceryAdvance: 55,
      gmv: 210.2,
      onTime: false,
      repeatClient: true,
      promoCode: 'WELCOME15',
    },
    {
      id: 'ORD-3388',
      client: 'Howard Kim',
      cook: 'Chef Lina',
      stage: 'Dispatched',
      deliveryWindow: 'Today • 4:45 PM – 5:30 PM',
      region: 'Brooklyn',
      etaMinutes: 5,
      groceryAdvance: 70,
      gmv: 265,
      onTime: true,
      repeatClient: false,
    },
  ]);
  const [payouts, setPayouts] = useState<PendingPayout[]>([
    {
      id: 'PAYOUT-221',
      orderId: 'ORD-3388',
      cook: 'Chef Lina',
      amount: 195,
      scheduledFor: 'Tonight • 9:00 PM',
      status: 'Ready',
    },
    {
      id: 'PAYOUT-218',
      orderId: 'ORD-3409',
      cook: 'Chef Malik',
      amount: 162.5,
      scheduledFor: 'Tomorrow • 10:00 AM',
      status: 'Pending',
    },
    {
      id: 'PAYOUT-215',
      orderId: 'ORD-3375',
      cook: 'Chef Naomi',
      amount: 184.25,
      scheduledFor: 'Awaiting dispute clearance',
      status: 'On Hold',
    },
  ]);
  const [disputes, setDisputes] = useState<DisputeTicket[]>([
    {
      id: 'DSP-117',
      orderId: 'ORD-3375',
      openedAt: 'Today • 2:05 PM',
      reportedBy: 'Client',
      summary: 'Missing side dishes on delivery',
      amountAtRisk: 45,
      slaHoursRemaining: 10,
      status: 'Investigating',
    },
    {
      id: 'DSP-114',
      orderId: 'ORD-3322',
      openedAt: 'Yesterday • 8:41 PM',
      reportedBy: 'Cook',
      summary: 'Grocery advance adjustment requested',
      amountAtRisk: 28,
      slaHoursRemaining: 2,
      status: 'Waiting on Client',
    },
  ]);
  const [activity, setActivity] = useState<OrderActivity[]>([
    {
      id: 'log-1',
      orderId: 'ORD-3388',
      message: 'Dispatcher confirmed handoff and captured delivery photo.',
      timestamp: '4:52 PM',
      type: 'order-update',
    },
    {
      id: 'log-2',
      orderId: 'ORD-3409',
      message: 'System flagged ETA risk — 6 minute delay projected.',
      timestamp: '4:45 PM',
      type: 'order-update',
    },
    {
      id: 'log-3',
      orderId: 'ORD-3375',
      message: 'Dispute DSP-117 escalated to senior admin.',
      timestamp: '3:18 PM',
      type: 'dispute',
    },
  ]);
  const [selectedOrderId, setSelectedOrderId] = useState<string>('ORD-3421');
  const [lastRefresh, setLastRefresh] = useState<Date>(new Date());

  const [refundAmount, setRefundAmount] = useState<string>('15');
  const [refundReason, setRefundReason] = useState<string>('Partial refund for missing item');
  const [advanceAdjustment, setAdvanceAdjustment] = useState<string>('');
  const [promoCode, setPromoCode] = useState<string>('THANKS10');
  const [promoNotes, setPromoNotes] = useState<string>('Retention credit for delayed delivery');
  const [exportPresetId, setExportPresetId] = useState<string>('today-performance');

  useEffect(() => {
    const refreshInterval = setInterval(() => {
      setLastRefresh(new Date());
    }, 30_000);

    return () => clearInterval(refreshInterval);
  }, []);

  const presets: ExportPreset[] = useMemo(
    () => [
      {
        id: 'today-performance',
        label: 'Today\'s performance snapshot',
        description: 'GMV, delivery rate, repeat clients for the active shift.',
        metrics: [
          { name: 'Gross Merchandise Volume', value: formatCurrency(orders.reduce((sum, order) => sum + order.gmv, 0)), trend: '+12% vs yesterday' },
          { name: 'On-time delivery rate', value: `${Math.round((orders.filter((order) => order.onTime).length / orders.length) * 100)}%`, trend: '+4 pts vs last week' },
          { name: 'Repeat clients served', value: orders.filter((order) => order.repeatClient).length, trend: '+2 vs yesterday' },
        ],
      },
      {
        id: 'week-to-date',
        label: 'Week-to-date KPIs',
        description: 'Aggregated GMV, disputes resolved, and promos applied WTD.',
        metrics: [
          { name: 'GMV', value: '$42,810', trend: '+8% WoW' },
          { name: 'Disputes resolved', value: 18, trend: '-3 vs goal' },
          { name: 'Promo credits issued', value: '$1,125', trend: '+5% vs plan' },
        ],
      },
      {
        id: 'monthly-investor',
        label: 'Investor KPI package',
        description: 'GMV, cohort retention, delivery SLA compliance, and NPS.',
        metrics: [
          { name: 'Monthly GMV', value: '$188,420', trend: '+19% MoM' },
          { name: 'Cohort repeat rate (30d)', value: '41%', trend: '+3 pts MoM' },
          { name: 'On-time deliveries', value: '94%', trend: '+1 pt MoM' },
          { name: 'Net Promoter Score', value: '56', trend: '+4 MoM' },
        ],
      },
    ],
    [orders],
  );

  const filteredOrders = useMemo(() => {
    return orders.filter((order) => {
      const matchesRegion = regionFilter === 'all' || order.region === regionFilter;
      const matchesStatus = statusFilter === 'all' || order.stage === statusFilter;

      if (!matchesRegion || !matchesStatus) {
        return false;
      }

      // Today-only data in mock set so timeRange filter is informational here.
      return true;
    });
  }, [orders, regionFilter, statusFilter]);

  const selectedOrder = useMemo(
    () => orders.find((order) => order.id === selectedOrderId) ?? orders[0],
    [orders, selectedOrderId],
  );

  const metrics = useMemo(() => {
    const activeCount = filteredOrders.length;
    const totalGmv = filteredOrders.reduce((sum, order) => sum + order.gmv, 0);
    const onTimeRate =
      filteredOrders.length === 0
        ? '0%'
        : `${Math.round((filteredOrders.filter((order) => order.onTime).length / filteredOrders.length) * 100)}%`;
    const disputesOpen = disputes.filter((ticket) => ticket.status !== 'Resolved').length;

    return {
      activeCount,
      totalGmv,
      onTimeRate,
      disputesOpen,
    };
  }, [filteredOrders, disputes]);

  const handleManualRefresh = () => {
    setLastRefresh(new Date());
    setActivity((prev) => [
      {
        id: `log-${prev.length + 1}`,
        orderId: 'SYSTEM',
        message: 'Dashboard metrics refreshed.',
        timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }),
        type: 'order-update',
      },
      ...prev,
    ]);
  };

  const appendLog = (entry: Omit<OrderActivity, 'id'>) => {
    setActivity((prev) => [
      {
        id: `log-${prev.length + 1}`,
        ...entry,
      },
      ...prev,
    ]);
  };

  const issueRefund = (orderId: string | undefined, amount: string, reason: string) => {
    if (!orderId || !amount) return;

    appendLog({
      orderId,
      message: `Refund of ${formatCurrency(Number(amount))} initiated — ${reason}.`,
      timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }),
      type: 'refund',
    });
  };

  const handleIssueRefund = () => {
    issueRefund(selectedOrder?.id, refundAmount, refundReason);
    setRefundAmount('');
  };

  const handleAdjustAdvance = () => {
    const orderId = selectedOrder?.id;
    if (!orderId || !advanceAdjustment) return;

    const adjustmentValue = Number(advanceAdjustment);
    setOrders((prev) =>
      prev.map((order) =>
        order.id === orderId
          ? {
              ...order,
              groceryAdvance: Math.max(0, adjustmentValue),
            }
          : order,
      ),
    );

    appendLog({
      orderId,
      message: `Grocery advance set to ${formatCurrency(adjustmentValue)}.`,
      timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }),
      type: 'order-update',
    });

    setAdvanceAdjustment('');
  };

  const handleApplyPromo = () => {
    const orderId = selectedOrder?.id;
    if (!orderId || !promoCode) return;

    setOrders((prev) =>
      prev.map((order) =>
        order.id === orderId
          ? {
              ...order,
              promoCode,
            }
          : order,
      ),
    );

    appendLog({
      orderId,
      message: `Promo ${promoCode.toUpperCase()} applied. ${promoNotes}`,
      timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }),
      type: 'order-update',
    });
  };

  const handleReleasePayout = (payoutId: string) => {
    setPayouts((prev) =>
      prev.map((payout) =>
        payout.id === payoutId
          ? {
              ...payout,
              status: 'Released',
              scheduledFor: 'Released just now',
            }
          : payout,
      ),
    );

    appendLog({
      orderId: payoutId,
      message: `Payout ${payoutId} released to cook bank account.`,
      timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }),
      type: 'payout',
    });
  };

  const handleEscalateDispute = (disputeId: string) => {
    setDisputes((prev) =>
      prev.map((ticket) =>
        ticket.id === disputeId
          ? {
              ...ticket,
              status: 'Investigating',
              slaHoursRemaining: Math.max(1, ticket.slaHoursRemaining - 1),
            }
          : ticket,
      ),
    );

    appendLog({
      orderId: disputeId,
      message: `Dispute ${disputeId} escalated for supervisor review.`,
      timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }),
      type: 'dispute',
    });
  };

  const handleResolveDispute = (disputeId: string) => {
    setDisputes((prev) =>
      prev.map((ticket) =>
        ticket.id === disputeId
          ? {
              ...ticket,
              status: 'Resolved',
              slaHoursRemaining: 0,
            }
          : ticket,
      ),
    );

    appendLog({
      orderId: disputeId,
      message: `Dispute ${disputeId} resolved and closed.`,
      timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }),
      type: 'dispute',
    });
  };

  const handleExportPreset = () => {
    const preset = presets.find((item) => item.id === exportPresetId);
    if (!preset) return;

    const csvRows = [
      ['Metric', 'Value', 'Trend'],
      ...preset.metrics.map((metric) => [metric.name, String(metric.value), metric.trend]),
    ];

    const csvContent = csvRows.map((row) => row.map((value) => `"${value.replace(/"/g, '""')}"`).join(',')).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const downloadLink = document.createElement('a');
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.setAttribute('download', `${preset.id}.csv`);
    downloadLink.click();
    URL.revokeObjectURL(downloadLink.href);

    appendLog({
      orderId: 'REPORT',
      message: `${preset.label} exported as CSV.`,
      timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }),
      type: 'export',
    });
  };

  return (
    <div className="space-y-8">
      <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-black dark:text-white">Operations monitoring</h1>
          <p className="text-sm text-bodydark2">
            Track live order health, payout readiness, dispute triage, and export KPIs for stakeholders.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <div className="rounded-full bg-success/10 px-4 py-1 text-xs font-medium text-success">
            Live as of {lastRefresh.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })}
          </div>
          <button
            type="button"
            onClick={handleManualRefresh}
            className="inline-flex items-center gap-2 rounded-lg border border-primary px-4 py-2 text-sm font-medium text-primary transition hover:bg-primary/10"
          >
            <svg
              className="h-4 w-4"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M16.023 9.348H21v-6m0 0-4.977 4.977A9 9 0 1 0 21 12.03"
              />
            </svg>
            Refresh
          </button>
        </div>
      </header>

      <section>
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-2 rounded-full border border-stroke bg-white px-3 py-1 text-xs font-medium shadow-sm dark:border-strokedark dark:bg-boxdark">
            <span className="text-bodydark2">Time range:</span>
            <select
              value={timeRange}
              onChange={(event) => setTimeRange(event.target.value as typeof timeRange)}
              className="border-none bg-transparent text-sm font-semibold text-black focus:outline-none dark:text-white"
            >
              <option value="today">Today</option>
              <option value="7d">Last 7 days</option>
              <option value="30d">Last 30 days</option>
            </select>
          </div>
          <div className="flex items-center gap-2 rounded-full border border-stroke bg-white px-3 py-1 text-xs font-medium shadow-sm dark:border-strokedark dark:bg-boxdark">
            <span className="text-bodydark2">Region:</span>
            <select
              value={regionFilter}
              onChange={(event) => setRegionFilter(event.target.value as typeof regionFilter)}
              className="border-none bg-transparent text-sm font-semibold text-black focus:outline-none dark:text-white"
            >
              <option value="all">All</option>
              <option value="Brooklyn">Brooklyn</option>
              <option value="Manhattan">Manhattan</option>
              <option value="Queens">Queens</option>
            </select>
          </div>
          <div className="flex items-center gap-2 rounded-full border border-stroke bg-white px-3 py-1 text-xs font-medium shadow-sm dark:border-strokedark dark:bg-boxdark">
            <span className="text-bodydark2">Stage:</span>
            <select
              value={statusFilter}
              onChange={(event) => setStatusFilter(event.target.value as typeof statusFilter)}
              className="border-none bg-transparent text-sm font-semibold text-black focus:outline-none dark:text-white"
            >
              <option value="all">All</option>
              <option value="Pending">Pending</option>
              <option value="Accepted">Accepted</option>
              <option value="Cooking">Cooking</option>
              <option value="Ready for Dispatch">Ready for dispatch</option>
              <option value="Dispatched">Dispatched</option>
            </select>
          </div>
        </div>

        <div className="mt-6 grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
          <CardDataStats title="Active orders in flight" total={metrics.activeCount.toString()} rate={`${orders.length} total shift`}>
            <svg
              className="h-6 w-6 text-primary"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M3 3h18M9 7h6m-9 4h12m-9 4h6m-9 4h12"
              />
            </svg>
          </CardDataStats>
          <CardDataStats
            title="Gross merchandise value"
            total={formatCurrency(metrics.totalGmv)}
            rate="Shift-to-date"
            levelUp
          >
            <svg
              className="h-6 w-6 text-primary"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M12 8c-1.657 0-3 1.343-3 3m3-3c1.657 0 3 1.343 3 3m-3-3V5m0 6v6m-7 4h14a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2Z"
              />
            </svg>
          </CardDataStats>
          <CardDataStats title="On-time delivery rate" total={metrics.onTimeRate} rate="Goal ≥ 92%" levelUp>
            <svg
              className="h-6 w-6 text-primary"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M12 6v6l4 2"
              />
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M12 21a9 9 0 1 0-9-9 9 9 0 0 0 9 9Z"
              />
            </svg>
          </CardDataStats>
          <CardDataStats title="Open disputes" total={metrics.disputesOpen.toString()} rate="SLA 12h" levelDown={metrics.disputesOpen > 0}>
            <svg
              className="h-6 w-6 text-primary"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M12 9v3m0 4h.01M4.318 4.318a4.5 4.5 0 0 1 6.364 0L12 5.636l1.318-1.318a4.5 4.5 0 0 1 6.364 6.364L12 18.364 4.318 10.682a4.5 4.5 0 0 1 0-6.364Z"
              />
            </svg>
          </CardDataStats>
        </div>
      </section>

      <section className="grid grid-cols-1 gap-6 xl:grid-cols-3">
        <div className="space-y-4 xl:col-span-2">
          <div className="rounded-xl border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
            <header className="flex items-center justify-between border-b border-stroke px-6 py-4 dark:border-strokedark">
              <div>
                <h2 className="text-lg font-semibold text-black dark:text-white">Active orders</h2>
                <p className="text-xs text-bodydark2">Monitor prep and delivery status, with instant context.</p>
              </div>
              <span className="rounded-full bg-primary/10 px-3 py-1 text-xs font-medium text-primary">
                {filteredOrders.length} visible
              </span>
            </header>

            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-stroke text-left text-sm dark:divide-strokedark">
                <thead className="bg-whiter dark:bg-meta-4">
                  <tr>
                    <th className="px-6 py-3 font-semibold text-black dark:text-white">Order</th>
                    <th className="px-6 py-3 font-semibold text-black dark:text-white">Cook</th>
                    <th className="px-6 py-3 font-semibold text-black dark:text-white">Stage</th>
                    <th className="px-6 py-3 font-semibold text-black dark:text-white">Delivery window</th>
                    <th className="px-6 py-3 font-semibold text-black dark:text-white">GMV</th>
                    <th className="px-6 py-3 font-semibold text-black dark:text-white">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-stroke dark:divide-strokedark">
                  {filteredOrders.map((order) => {
                    const isSelected = order.id === selectedOrder?.id;
                    return (
                      <tr
                        key={order.id}
                        className={`${isSelected ? 'bg-primary/5 dark:bg-primary/10' : 'bg-white dark:bg-boxdark'} transition-colors`}
                      >
                        <td className="px-6 py-4">
                          <div className="flex flex-col">
                            <span className="font-semibold text-black dark:text-white">{order.id}</span>
                            <span className="text-xs text-bodydark2">{order.client}</span>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="flex flex-col">
                            <span className="font-medium text-black dark:text-white">{order.cook}</span>
                            <span className="text-xs text-bodydark2">
                              Advance {formatCurrency(order.groceryAdvance)}
                            </span>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <span
                            className={`inline-flex rounded-full px-3 py-1 text-xs font-semibold ${
                              order.stage === 'Ready for Dispatch'
                                ? 'bg-warning/10 text-warning'
                                : order.stage === 'Dispatched'
                                ? 'bg-success/10 text-success'
                                : 'bg-primary/10 text-primary'
                            }`}
                          >
                            {order.stage}
                          </span>
                          <div className={`mt-1 text-xs font-medium ${order.onTime ? 'text-success' : 'text-warning'}`}>
                            {order.onTime ? 'On schedule' : `Delay: ${order.etaMinutes} min`}
                          </div>
                        </td>
                        <td className="px-6 py-4 text-sm text-bodydark2">
                          <div>{order.deliveryWindow}</div>
                          <div className="text-xs text-bodydark2">ETA {order.etaMinutes} min</div>
                        </td>
                        <td className="px-6 py-4 text-sm font-semibold text-black dark:text-white">
                          {formatCurrency(order.gmv)}
                        </td>
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-2">
                            <button
                              type="button"
                              onClick={() => setSelectedOrderId(order.id)}
                              className={`rounded-lg border px-3 py-1 text-xs font-medium transition ${
                                isSelected
                                  ? 'border-primary bg-primary text-white'
                                  : 'border-stroke text-black hover:border-primary hover:text-primary dark:border-strokedark dark:text-white'
                              }`}
                            >
                              View
                            </button>
                            <button
                              type="button"
                              onClick={() => {
                                setSelectedOrderId(order.id);
                                issueRefund(order.id, '15', 'Quick service recovery refund');
                              }}
                              className="rounded-lg border border-warning/50 bg-warning/10 px-3 py-1 text-xs font-medium text-warning transition hover:border-warning hover:bg-warning/20"
                            >
                              Quick refund
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>

          {selectedOrder && (
            <div className="rounded-xl border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
              <header className="flex items-center justify-between border-b border-stroke px-6 py-4 dark:border-strokedark">
                <div>
                  <h3 className="text-lg font-semibold text-black dark:text-white">Order context</h3>
                  <p className="text-xs text-bodydark2">Granular details to inform interventions.</p>
                </div>
                <div className="text-right text-xs text-bodydark2">
                  <div>Order {selectedOrder.id}</div>
                  <div>{selectedOrder.deliveryWindow}</div>
                </div>
              </header>
              <div className="grid grid-cols-1 gap-6 px-6 py-5 md:grid-cols-2">
                <div className="space-y-3">
                  <div>
                    <span className="text-xs uppercase text-bodydark2">Client</span>
                    <p className="text-sm font-semibold text-black dark:text-white">{selectedOrder.client}</p>
                  </div>
                  <div>
                    <span className="text-xs uppercase text-bodydark2">Cook</span>
                    <p className="text-sm font-semibold text-black dark:text-white">{selectedOrder.cook}</p>
                    <p className="text-xs text-bodydark2">
                      Grocery advance {formatCurrency(selectedOrder.groceryAdvance)} · GMV {formatCurrency(selectedOrder.gmv)}
                    </p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {selectedOrder.dietaryFlags?.map((flag) => (
                      <span key={flag} className="rounded-full bg-meta-2 px-2 py-1 text-xs font-medium text-bodydark1 dark:bg-meta-4 dark:text-white">
                        {flag}
                      </span>
                    ))}
                    {selectedOrder.repeatClient && (
                      <span className="rounded-full bg-success/10 px-2 py-1 text-xs font-semibold text-success">Repeat client</span>
                    )}
                    {selectedOrder.promoCode && (
                      <span className="rounded-full bg-primary/10 px-2 py-1 text-xs font-semibold text-primary">
                        Promo: {selectedOrder.promoCode}
                      </span>
                    )}
                  </div>
                </div>
                <div className="space-y-3">
                  <div>
                    <span className="text-xs uppercase text-bodydark2">Current stage</span>
                    <p className="text-sm font-semibold text-black dark:text-white">{selectedOrder.stage}</p>
                    <p className="text-xs text-bodydark2">ETA {selectedOrder.etaMinutes} min · {selectedOrder.onTime ? 'On schedule' : 'Watch for delay'}</p>
                  </div>
                  <div>
                    <span className="text-xs uppercase text-bodydark2">Region</span>
                    <p className="text-sm font-semibold text-black dark:text-white">{selectedOrder.region}</p>
                  </div>
                  <div>
                    <span className="text-xs uppercase text-bodydark2">Admin notes</span>
                    <p className="text-xs text-bodydark2">
                      Use the actions below to issue refunds, adjust advances, or provide courtesy credits without leaving the dashboard.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        <aside className="space-y-4">
          <div className="rounded-xl border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
            <header className="flex items-center justify-between border-b border-stroke px-6 py-4 dark:border-strokedark">
              <h2 className="text-lg font-semibold text-black dark:text-white">Action tools</h2>
              <span className="text-xs text-bodydark2">Impacts {selectedOrder?.id ?? '—'}</span>
            </header>
            <div className="space-y-5 px-6 py-5">
              <div className="space-y-2">
                <div className="text-sm font-semibold text-black dark:text-white">Issue refund</div>
                <div className="flex items-center gap-2">
                  <input
                    type="number"
                    min="0"
                    value={refundAmount}
                    onChange={(event) => setRefundAmount(event.target.value)}
                    className="w-24 rounded-lg border border-stroke px-3 py-2 text-sm focus:border-primary focus:outline-none dark:border-strokedark dark:bg-boxdark"
                    placeholder="Amount"
                  />
                  <input
                    type="text"
                    value={refundReason}
                    onChange={(event) => setRefundReason(event.target.value)}
                    className="flex-1 rounded-lg border border-stroke px-3 py-2 text-sm focus:border-primary focus:outline-none dark:border-strokedark dark:bg-boxdark"
                    placeholder="Reason"
                  />
                  <button
                    type="button"
                    onClick={handleIssueRefund}
                    className="rounded-lg bg-warning px-4 py-2 text-xs font-semibold text-white transition hover:bg-warning/80"
                  >
                    Send
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <div className="text-sm font-semibold text-black dark:text-white">Adjust grocery advance</div>
                <div className="flex items-center gap-2">
                  <input
                    type="number"
                    min="0"
                    value={advanceAdjustment}
                    onChange={(event) => setAdvanceAdjustment(event.target.value)}
                    className="w-32 rounded-lg border border-stroke px-3 py-2 text-sm focus:border-primary focus:outline-none dark:border-strokedark dark:bg-boxdark"
                    placeholder="New advance"
                  />
                  <button
                    type="button"
                    onClick={handleAdjustAdvance}
                    className="rounded-lg bg-primary px-4 py-2 text-xs font-semibold text-white transition hover:bg-primary/80"
                  >
                    Update
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <div className="text-sm font-semibold text-black dark:text-white">Apply promo code</div>
                <div className="flex items-center gap-2">
                  <input
                    type="text"
                    value={promoCode}
                    onChange={(event) => setPromoCode(event.target.value.toUpperCase())}
                    className="w-32 rounded-lg border border-stroke px-3 py-2 text-sm uppercase focus:border-primary focus:outline-none dark:border-strokedark dark:bg-boxdark"
                    placeholder="Code"
                  />
                  <input
                    type="text"
                    value={promoNotes}
                    onChange={(event) => setPromoNotes(event.target.value)}
                    className="flex-1 rounded-lg border border-stroke px-3 py-2 text-sm focus:border-primary focus:outline-none dark:border-strokedark dark:bg-boxdark"
                    placeholder="Customer notes"
                  />
                  <button
                    type="button"
                    onClick={handleApplyPromo}
                    className="rounded-lg bg-success px-4 py-2 text-xs font-semibold text-white transition hover:bg-success/80"
                  >
                    Apply
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div className="rounded-xl border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
            <header className="flex items-center justify-between border-b border-stroke px-6 py-4 dark:border-strokedark">
              <h2 className="text-lg font-semibold text-black dark:text-white">Live activity</h2>
              <span className="text-xs text-bodydark2">Newest first</span>
            </header>
            <div className="space-y-4 px-6 py-5">
              {activity.slice(0, 6).map((entry) => (
                <div key={entry.id} className="border-l-2 border-primary/40 pl-3">
                  <div className="flex items-center justify-between text-xs text-bodydark2">
                    <span>{entry.timestamp}</span>
                    <span className="uppercase tracking-wide text-primary">{entry.type}</span>
                  </div>
                  <div className="text-sm text-black dark:text-white">{entry.message}</div>
                </div>
              ))}
              {activity.length === 0 && (
                <div className="text-sm text-bodydark2">No events yet. Actions will appear here in real-time.</div>
              )}
            </div>
          </div>
        </aside>
      </section>

      <section className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <div className="rounded-xl border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
          <header className="flex items-center justify-between border-b border-stroke px-6 py-4 dark:border-strokedark">
            <h2 className="text-lg font-semibold text-black dark:text-white">Payout readiness</h2>
            <span className="text-xs text-bodydark2">{payouts.filter((payout) => payout.status !== 'Released').length} awaiting action</span>
          </header>
          <div className="divide-y divide-stroke px-6 dark:divide-strokedark">
            {payouts.map((payout) => (
              <div key={payout.id} className="flex flex-col gap-3 py-4 md:flex-row md:items-center md:justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-semibold text-black dark:text-white">{payout.id}</span>
                    <span className="text-xs text-bodydark2">Order {payout.orderId}</span>
                  </div>
                  <div className="text-xs text-bodydark2">
                    {payout.cook} • {payout.scheduledFor}
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <span className="text-sm font-semibold text-black dark:text-white">{formatCurrency(payout.amount)}</span>
                  <span
                    className={`rounded-full px-3 py-1 text-xs font-semibold ${
                      payout.status === 'Ready'
                        ? 'bg-success/10 text-success'
                        : payout.status === 'Pending'
                        ? 'bg-primary/10 text-primary'
                        : payout.status === 'On Hold'
                        ? 'bg-warning/10 text-warning'
                        : 'bg-meta-2 text-bodydark1 dark:bg-meta-4 dark:text-white'
                    }`}
                  >
                    {payout.status}
                  </span>
                  {payout.status !== 'Released' && (
                    <button
                      type="button"
                      onClick={() => handleReleasePayout(payout.id)}
                      className="rounded-lg border border-success px-3 py-1 text-xs font-semibold text-success transition hover:bg-success/10"
                    >
                      Release
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-xl border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
          <header className="flex items-center justify-between border-b border-stroke px-6 py-4 dark:border-strokedark">
            <h2 className="text-lg font-semibold text-black dark:text-white">Dispute triage</h2>
            <span className="text-xs text-bodydark2">Resolve within SLA</span>
          </header>
          <div className="divide-y divide-stroke px-6 dark:divide-strokedark">
            {disputes.map((ticket) => (
              <div key={ticket.id} className="flex flex-col gap-3 py-4">
                <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-sm font-semibold text-black dark:text-white">{ticket.id}</span>
                      <span className="text-xs text-bodydark2">Order {ticket.orderId}</span>
                    </div>
                    <p className="text-xs text-bodydark2">{ticket.summary}</p>
                    <p className="text-xs text-bodydark2">Reported by {ticket.reportedBy} • {ticket.openedAt}</p>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-sm font-semibold text-black dark:text-white">{formatCurrency(ticket.amountAtRisk)}</span>
                    <span className="rounded-full bg-warning/10 px-3 py-1 text-xs font-semibold text-warning">
                      SLA {ticket.slaHoursRemaining}h
                    </span>
                    <span
                      className={`rounded-full px-3 py-1 text-xs font-semibold ${
                        ticket.status === 'Resolved'
                          ? 'bg-success/10 text-success'
                          : ticket.status === 'Waiting on Client'
                          ? 'bg-warning/10 text-warning'
                          : 'bg-primary/10 text-primary'
                      }`}
                    >
                      {ticket.status}
                    </span>
                  </div>
                </div>
                <div className="flex flex-wrap gap-2">
                  <button
                    type="button"
                    onClick={() => handleEscalateDispute(ticket.id)}
                    className="rounded-lg border border-primary px-3 py-1 text-xs font-semibold text-primary transition hover:bg-primary/10"
                  >
                    Escalate
                  </button>
                  <button
                    type="button"
                    onClick={() => handleResolveDispute(ticket.id)}
                    className="rounded-lg border border-success px-3 py-1 text-xs font-semibold text-success transition hover:bg-success/10"
                  >
                    Mark resolved
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <div className="rounded-xl border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
          <header className="flex items-center justify-between border-b border-stroke px-6 py-4 dark:border-strokedark">
            <h2 className="text-lg font-semibold text-black dark:text-white">Export KPI reports</h2>
            <span className="text-xs text-bodydark2">CSV download</span>
          </header>
          <div className="space-y-4 px-6 py-5">
            <label className="flex flex-col gap-2 text-sm text-black dark:text-white">
              Choose preset
              <select
                value={exportPresetId}
                onChange={(event) => setExportPresetId(event.target.value)}
                className="rounded-lg border border-stroke px-3 py-2 text-sm focus:border-primary focus:outline-none dark:border-strokedark dark:bg-boxdark"
              >
                {presets.map((preset) => (
                  <option key={preset.id} value={preset.id}>
                    {preset.label}
                  </option>
                ))}
              </select>
            </label>
            <div className="space-y-2 rounded-lg bg-whiter px-4 py-3 text-sm text-bodydark2 dark:bg-meta-4">
              {presets
                .find((preset) => preset.id === exportPresetId)
                ?.metrics.map((metric) => (
                  <div key={metric.name} className="flex items-center justify-between">
                    <span className="font-medium text-black dark:text-white">{metric.name}</span>
                    <div className="text-right">
                      <div className="font-semibold text-black dark:text-white">{metric.value}</div>
                      <div className="text-xs text-primary">{metric.trend}</div>
                    </div>
                  </div>
                ))}
            </div>
            <button
              type="button"
              onClick={handleExportPreset}
              className="inline-flex items-center justify-center gap-2 rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white transition hover:bg-primary/80"
            >
              <svg
                className="h-4 w-4"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M7.5 12 12 16.5m0 0L16.5 12m-4.5 4.5V3"
                />
              </svg>
              Export CSV
            </button>
          </div>
        </div>

        <div className="rounded-xl border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
          <header className="flex items-center justify-between border-b border-stroke px-6 py-4 dark:border-strokedark">
            <h2 className="text-lg font-semibold text-black dark:text-white">Operations playbook</h2>
            <span className="text-xs text-bodydark2">Best-practice prompts</span>
          </header>
          <div className="space-y-4 px-6 py-5 text-sm text-bodydark2">
            <div>
              <div className="text-sm font-semibold text-black dark:text-white">Refund decisioning</div>
              <p>
                Apply refunds under $25 instantly to keep CSAT high. For larger amounts, tag finance in the dispute and log evidence in the
                ticket.
              </p>
            </div>
            <div>
              <div className="text-sm font-semibold text-black dark:text-white">Grocery advance adjustments</div>
              <p>
                Advances should not exceed 35% of GMV without approval. If ingredient costs surge, document vendor receipts before updating the
                advance amount.
              </p>
            </div>
            <div>
              <div className="text-sm font-semibold text-black dark:text-white">Promo strategy</div>
              <p>
                Courtesy credits (THANKS10, VIP20) convert delayed deliveries into repeat bookings 63% of the time. Pair promo with a follow-up
                concierge message.
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default OperationsMonitoring;
