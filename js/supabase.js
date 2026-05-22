const SUPABASE_URL = 'https://kpjepfgukdfpuvwqyosx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwamVwZmd1a2RmcHV2d3F5b3N4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxMDc0OTMsImV4cCI6MjA5NDY4MzQ5M30.o1160[...]';

const { createClient } = supabase;

const db = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: {
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: true
    }
});

// ------------------------------------------------
// AUTH HELPERS
// ------------------------------------------------

async function getSession() {
    const { data: { session }, error } = await db.auth.getSession();
    return session;
}

async function getProfile(userId) {
    const { data, error } = await db
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();
    return { data, error };
}

async function requireAuth(redirectTo = 'index.html') {
    const session = await getSession();
    if (!session) {
        window.location.href = redirectTo;
        return null;
    }
    return session;
}

async function requireAdmin(redirectTo = 'admin-login.html') {
    const session = await getSession();
    if (!session) {
        window.location.href = redirectTo;
        return null;
    }
    const { data: profile } = await getProfile(session.user.id);
    if (!profile || profile.role !== 'admin') {
        window.location.href = redirectTo;
        return null;
    }
    return { session, profile };
}

async function requireClient(redirectTo = 'index.html') {
    const session = await getSession();
    if (!session) {
        window.location.href = redirectTo;
        return null;
    }
    const { data: profile } = await getProfile(session.user.id);
    if (!profile) {
        window.location.href = redirectTo;
        return null;
    }
    if (!profile.is_active) {
        await db.auth.signOut();
        window.location.href = redirectTo + '?suspended=1';
        return null;
    }
    if (profile.role === 'admin') {
        window.location.href = 'admin-dashboard.html';
        return null;
    }
    return { session, profile };
}

async function signOut(redirectTo = 'index.html') {
    await db.auth.signOut();
    window.location.href = redirectTo;
}

// ------------------------------------------------
// INVESTOR ID HELPER
// ------------------------------------------------

async function generateInvestorId() {
    const { data, error } = await db
        .from('profiles')
        .select('investor_id')
        .like('investor_id', 'MFH-%')
        .neq('investor_id', 'MFH-ADMIN');

    if (error) return 'MFH-001';
    const count = (data?.length || 0) + 1;
    return 'MFH-' + String(count).padStart(3, '0');
}

// ------------------------------------------------
// AUDIT LOG HELPER
// ------------------------------------------------

async function logAudit(adminId, clientId, action, oldValue = null, newValue = null) {
    await db.from('audit_log').insert({
        admin_id: adminId,
        client_id: clientId,
        action: action,
        old_value: oldValue ? JSON.stringify(oldValue) : null,
        new_value: newValue ? JSON.stringify(newValue) : null
    });
}

// ------------------------------------------------
// FORMAT HELPERS
// ------------------------------------------------

function formatCurrency(amount) {
    if (amount === null || amount === undefined) return '0.00';
    return new Intl.NumberFormat('en-IN', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    }).format(amount);
}

function formatDate(dateStr) {
    if (!dateStr) return '-';
    return new Date(dateStr).toLocaleDateString('en-IN', {
        day: '2-digit',
        month: 'short',
        year: 'numeric'
    });
}

function getProfitColor(value) {
    if (value > 0) return '#00C896';
    if (value < 0) return '#FF4D4D';
    return '#8B95A1';
}

function getProfitPrefix(value) {
    if (value > 0) return '+';
    return '';
}